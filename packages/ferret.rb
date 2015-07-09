class Ferret < PACKMAN::Package
  url 'ftp://ftp.pmel.noaa.gov/ferret/pub/source/fer_source.v693.tar.gz'
  sha1 '1b63fa4c6577db871f705cabe05ebbee6f3811cd'
  version '6.93'

  label :compiler_insensitive

  depends_on 'readline'
  depends_on 'lesstif'
  depends_on 'libxml2'
  depends_on 'jpeg'
  depends_on 'hdf4'
  depends_on 'hdf5'
  depends_on 'netcdf'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'curl'
  depends_on 'opendap'
  depends_on 'tcsh'

  attach 'dsets' do
    url 'ftp://ftp.pmel.noaa.gov/ferret/pub/data/fer_dsets.tar.gz'
    sha1 '4a1e3dfdad94f93a70f0359f3a88f65c342d8d39'
  end

  def install
    PACKMAN.has_compiler? 'fortran'
    # Ferret's tar file contains two extra plain files which messes up PACKMAN.
    PACKMAN.cd 'FERRET', :norecord
    # Check build type since Ferret does not check it for us.
    build_type = ''
    if PACKMAN.os.x86_64?
      if PACKMAN.mac?
        build_type = 'x86_64-darwin'
      elsif PACKMAN.linux?
        build_type = 'x86_64-linux'
      end
    else
      if PACKMAN.mac?
        build_type = 'i386-apple-darwin'
      elsif PACKMAN.linux?
        build_type = 'i386-linux'
      end
    end
    # Change configuration.
    PACKMAN.replace 'site_specific.mk', {
      /^BUILDTYPE\s*=.*$/ => "BUILDTYPE = #{build_type}",
      /^INSTALL_FER_DIR\s*=.*$/ => "INSTALL_FER_DIR = #{prefix}",
      /^HDF5_DIR\s*=.*$/ => "HDF5_DIR = #{Hdf5.prefix}",
      /^NETCDF4_DIR\s*=.*$/ => "NETCDF4_DIR = #{Netcdf.prefix}",
      /^LIBZ_DIR\s*=.*$/ => "LIBZ_DIR = #{Zlib.prefix}"
    }
    PACKMAN.replace "platform_specific.mk.#{build_type}", {
      /^(\s*INCLUDES\s*=.*)$/ => "\\1\n-I#{Netcdf.include} -I#{Curl.include} \\",
      /^(\s*LDFLAGS\s*=.*)$/ => "\\1 -L#{Netcdf.lib} -L#{Curl.lib} ",
    }
    if PACKMAN.mac?
      PACKMAN.replace "platform_specific.mk.#{build_type}", {
        /^TMAP_LOCAL\s*=.*$/ => "TMAP_LOCAL = #{FileUtils.pwd}",
        /^(\s*INCLUDES\s*=.*)$/ => "\\1\n-I/usr/X11R6/include \\",
        /^CPP\s*=.*$/ => 'CPP = /usr/bin/cpp',
        /^LD\s*=.*$/ => 'LD = gcc',
        /^READLINELIB\s*=.*$/ => 'READLINELIB = -lreadline -ltermcap',
        /^HDFLIB\s*=.*$/ => "HDFLIB = -L#{Hdf4.lib} -ldf -L#{Jpeg.lib} -ljpeg -L#{Zlib.lib} -lz",
        /^CDFLIB\s*=.*$/ => "CDFLIB = -L#{Netcdf.lib} -lnetcdf -lnetcdff "+
        "-L#{Hdf5.lib} -lhdf5_hl -lhdf5 "+
        "-L#{Zlib.lib} -lz -lm -L#{Szip.lib} -lsz -L#{Opendap.lib} -ldap -ldapclient "+
        "-L#{Curl.lib} -lcurl -L#{Libxml2.prefix} -lxml2 -lpthread -licucore -lstdc++",
        /\/usr\/local\/lib\/libXm.a/ => "#{Lesstif.lib}/libXm.a",
        # Why Ferret developers put fixed intel library into the configuration file??
        /\/opt\/intel\/Compiler\/11\.1\/058\/lib\/lib\{ifcore,ifport,irc,imf,svml\}\.a/ => '',
        # Why Ferret developers write a wrong library path??
        /^GKSLIB\s*=.*$/ => "GKSLIB = -L$(TMAP_LOCAL)/xgks/src/lib -lxgks",
        /-llist/ => '',
        /^(\s*SYSLIB\s*=.*)$/ => '\1 -lgfortran'
      }
      PACKMAN.replace "external_functions/ef_utility/platform_specific.mk.#{build_type}", {
        /^(\s*FFLAGS\s*=.*)$/ => 'FFLAGS = -fPIC -m64 -Ddouble_p -fno-second-underscore '+
        '-fno-backslash -fdollar-ok -ffixed-line-length-132 '+
        '-fdefault-real-8 -fdefault-double-8 $(FINCLUDES)'
      }
      PACKMAN.replace 'gksm2ps/Makefile', {
        /^i386-apple-darwin:$/ => "#{build_type}:",
        /CFLAGS="(.*)"/ => 'CFLAGS="\1 -I/usr/X11R6/include"'
      }
      if PACKMAN.compiler('fortran').vendor == 'gnu'
        # Fix the wrong compiler flags.
        PACKMAN.replace "platform_specific.mk.#{build_type}", {
          /^(CPP_FLAGS\s*=.*)$/ => "\\1\n-DMANDATORY_FORMAT_WIDTHS -DNO_OPEN_SHARED -DNO_OPEN_READONLY "+
          "-DNO_OPEN_RECORDTYPE -DNO_OPEN_CARRIAGECONTROL -Dreclen_in_bytes -DG77_SIGNAL -DG77 -DNEED_IAND "+
          "-DINTERNAL_READ_FORMAT_BUG -DNO_PREPEND_STRING -Ddouble_p \\",
          /^\s*PPLUS_FFLAGS\s*=.*$/ => 'PPLUS_FFLAGS = -fno-automatic -fno-second-underscore '+
          '-fdollar-ok -ffixed-line-length-132 -falign-commons -Dunix -DNEED_IAND -DFORTRAN_90 $(FINCLUDES)',
          /^\s*FFLAGS\s*=.*$/ => 'FFLAGS = -fno-automatic -fno-second-underscore -fdollar-ok '+
          '-ffixed-line-length-132 -falign-commons -ffpe-trap=overflow -fimplicit-none -fdefault-real-8 '+
          '-fdefault-double-8 -Dunix -DNEED_IAND -DFORTRAN_90 $(FINCLUDES)',
          /^(LD\s*=)/ => "PPLUS_FFLAGS += $(CPP_FLAGS)\nFFLAGS += $(CPP_FLAGS)\n\\1"
        }
      end
    else
      PACKMAN.replace 'site_specific.mk', {
        /^READLINE_DIR\s*=.*$/ => "READLINE_DIR = #{Readline.prefix}"
      }
      PACKMAN.replace "platform_specific.mk.#{build_type}", {
        /^(\s*TERMCAPLIB\s*=).*$/ => "\\1 -L#{Ncurses.lib} -lncurses"
      }
    end
    # Check if Xmu library is installed by system or not.
    if PACKMAN.mac?
      if not File.exist? '/usr/X11R6/include/X11/Xmu/WinUtil.h'
        PACKMAN.report_error "Mac does not install X11 (search Xquartz)."
      end
    else
      xmu_package = ''
      if PACKMAN.redhat?
        xmu_package = 'libXmu-devel'
      elsif PACKMAN.debian?
        xmu_package = 'libxmu-dev'
      end
      if not PACKMAN.os_installed? xmu_package
        PACKMAN.report_warning "System package "+
          "#{PACKMAN.red xmu_package} is not "+
          "installed! Macro NO_WIN_UTIL_H will be used."
        PACKMAN.report_warning "If you want Ferret to use WIN_UTIL and you "+
          "have root previledge, you can install #{xmu_package} and come back."
        PACKMAN.replace "platform_specific.mk.#{build_type}", {
          /^(\s*CPP_FLAGS\s*=.*)$/ => "\\1\n-DNO_WIN_UTIL_H \\"
        }
      end
    end
    # Bad Ferret developers! Shame on you!
    if build_type == 'x86_64-darwin'
      File.open('xgks/CUSTOMIZE.os.x86_64-darwin', 'w') do |file|
        file << "CC=#{PACKMAN.compiler('c').command}\n"
        file << "CFLAGS='#{PACKMAN.compiler('c').default_flags['c']}'\n"
        file << "CPPFLAGS='-DNDEBUG'\n"
        file << "FC=#{PACKMAN.compiler('fortran').command}\n"
        file << "FFLAGS='#{PACKMAN.compiler('fortran').default_flags['fortran']}'\n"
        file << "OS=macosx\n"
        file << "prefix=..\n"
        file << "CPP_X11='/usr/X11R6/include'\n"
        file << "LD_X11='-L/usr/X11R6/lib -lX11'\n"
      end
      PACKMAN.replace 'xgks/src/lib/cgm/Makefile.in', {
        /^INCLUDES\s*=/ => 'INCLUDES = -I/usr/X11R6/include'
      }
      # PACKMAN.replace 'fer/gnl/ctrl_c.F', {
      #   /IF \(first_call\) old_handler = SIGNAL\( 2, CTRLC_AST, -1 \)/ => 'IF (first_call) old_handler = SIGNAL( 2, CTRLC_AST )'
      # }
    end
    if PACKMAN.mac?
      PACKMAN.replace 'bin/make_executable_tar', {
        /^set mycp =.*$/ => 'set mycp = "/bin/cp -v -r -p"'
      }
    else
      # We need to dynamically link libgfortran.
      PACKMAN.replace "platform_specific.mk.#{build_type}", {
        /lib64/ => 'lib',
        /-Wl,-Bstatic -lgfortran/ => '-Wl,-Bdynamic -lgfortran'
      }
      # Since PACKMAN install different language APIs of Netcdf separately, we
      # need to specify the Fortran API explicitly.
      PACKMAN.replace "platform_specific.mk.#{build_type}", {
        /\$\(NETCDF4_DIR\)\/lib\/libnetcdff\.a/ => "#{Netcdf.lib}/libnetcdff.a",
        /^(\s*\$\(LIBZ_DIR\)\/lib\/libz.a)$/ => "\\1 \\\n#{Szip.lib}/libsz.a"
      }
    end
    # BUILDTYPE is not propagated into external_functions directory
    ['contributed', 'examples', 'fft', 'statistics'].each do |dir|
      PACKMAN.replace "external_functions/#{dir}/Makefile", {
        /\$\(BUILDTYPE\)/ => build_type
      }
    end
    # Make.
    # Bad Ferret developers! The BUILDTYPE is not cascaded into subdirectories.
    PACKMAN.run "make BUILDTYPE=#{build_type}"
    PACKMAN.run 'make install'
    PACKMAN.cd prefix, :norecord
    PACKMAN.decompress 'fer_environment.tar.gz'
    PACKMAN.cd File.dirname(prefix), :norecord
    PACKMAN.mkdir 'datasets', :force
    PACKMAN.work_in 'datasets' do
      PACKMAN.decompress dsets.package_path
    end
    # Do the final installation step.
    PACKMAN.work_in PACKMAN.prefix(self) do
      PACKMAN.rm 'ferret_paths.csh'
      PACKMAN.rm 'ferret_paths.sh'
      PTY.spawn('unset FER_DIR FER_DSETS; ./bin/Finstall') do |reader, writer, pid|
        reader.expect(/\(1, 2, 3, q, x\) --> /)
        writer.print("2\n")
        reader.expect(/FER_DIR --> /)
        writer.print("#{prefix}\n")
        reader.expect(/FER_DSETS --> /)
        writer.print("#{File.dirname(prefix)}/datasets\n")
        reader.expect(/desired ferret_paths location --> /)
        writer.print("#{prefix}\n")
        reader.expect(/ferret_paths link to create\? \(c\/s\/n\) \[n\] --> /)
        writer.print("n\n")
        reader.expect(/\(1, 2, 3, q, x\) --> /)
        writer.print("q\n")
      end
    end
  end

  def post_install
    # Ferret has put its shell configuration into 'ferret_paths.sh', so we
    # respect it.
    bashrc = "#{prefix}/bashrc"
    PACKMAN.rm bashrc
    File.open(bashrc, 'w') do |file|
      file << "# #{sha1}\n"
      file << "source #{PACKMAN.prefix self}/ferret_paths.sh\n"
    end
  end
end
