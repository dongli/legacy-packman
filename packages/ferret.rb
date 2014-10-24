class Ferret < PACKMAN::Package
  url 'ftp://ftp.pmel.noaa.gov/ferret/pub/source/fer_source.tar.gz'
  sha1 '8290af0fc18df2a6f3552f771a6c5140ef35a256'
  version '6.9'

  depends_on 'readline'
  depends_on 'jpeg'
  depends_on 'hdf4'
  depends_on 'hdf5'
  depends_on 'netcdf_c'
  depends_on 'netcdf_fortran'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'curl'
  depends_on 'opendap'
  depends_on 'tcsh'

  attach do
    url 'ftp://ftp.pmel.noaa.gov/ferret/pub/data/fer_dsets.tar.gz'
    sha1 '4a1e3dfdad94f93a70f0359f3a88f65c342d8d39'
  end

  def install
    # Ferret's tar file contains two extra plain files which messes up PACKMAN.
    PACKMAN.cd 'FERRET', :norecord
    ferret = PACKMAN.prefix(self)
    ncurses = PACKMAN.prefix(Ncurses)
    readline = PACKMAN.prefix(Readline)
    jpeg = PACKMAN.prefix(Jpeg)
    hdf4 = PACKMAN.prefix(Hdf4)
    hdf5 = PACKMAN.prefix(Hdf5)
    netcdf_c = PACKMAN.prefix(Netcdf_c)
    netcdf_fortran = PACKMAN.prefix(Netcdf_fortran)
    zlib = PACKMAN.prefix(Zlib)
    szip = PACKMAN.prefix(Szip)
    curl = PACKMAN.prefix(Curl)
    opendap = PACKMAN.prefix(Opendap)
    # Check build type since Ferret does not check it for us.
    build_type = ''
    if PACKMAN::OS.x86_64?
      case PACKMAN::OS.type
      when :Darwin
        build_type = 'x86_64-darwin'
      when :Linux
        build_type = 'x86_64-linux'
      end
    else
      case PACKMAN::OS.type
      when :Darwin
        build_type = 'i386-apple-darwin'
      when :Linux
        build_type = 'i386-linux'
      end
    end
    # Change configuration.
    PACKMAN.replace 'site_specific.mk', {
      /^BUILDTYPE\s*=.*$/ => "BUILDTYPE = #{build_type}",
      /^INSTALL_FER_DIR\s*=.*$/ => "INSTALL_FER_DIR = #{ferret}",
      /^HDF5_DIR\s*=.*$/ => "HDF5_DIR = #{hdf5}",
      /^NETCDF4_DIR\s*=.*$/ => "NETCDF4_DIR = #{netcdf_c}",
      /^LIBZ_DIR\s*=.*$/ => "LIBZ_DIR = #{zlib}"
    }
    PACKMAN.replace "platform_specific.mk.#{build_type}", {
      /^(\s*INCLUDES\s*=.*)$/ => "\\1\n-I#{netcdf_fortran}/include -I#{curl}/include \\",
      /^(\s*LDFLAGS\s*=.*)$/ => "\\1 -L#{netcdf_fortran}/lib -L#{curl}/lib ",
    }
    if PACKMAN::OS.mac_gang?
      PACKMAN.replace "platform_specific.mk.#{build_type}", {
        /^TMAP_LOCAL\s*=.*$/ => "TMAP_LOCAL = #{FileUtils.pwd}",
        /^(\s*INCLUDES\s*=.*)$/ => "\\1\n-I/usr/X11R6/include \\",
        /^CPP\s*=.*$/ => 'CPP = /usr/bin/cpp',
        /^LD\s*=.*$/ => 'LD = gcc',
        /^READLINELIB\s*=.*$/ => 'READLINELIB = -lreadline -ltermcap',
        /^HDFLIB\s*=.*$/ => "HDFLIB = -L#{hdf4}/lib -ldf -L#{jpeg}/lib -ljpeg -L#{zlib}/lib -lz",
        /^CDFLIB\s*=.*$/ => "CDFLIB = -L#{netcdf_c}/lib -lnetcdf -L#{netcdf_fortran}/lib -lnetcdff "+
        "-L#{hdf5}/lib -lhdf5_hl -lhdf5 "+
        "-L#{zlib}/lib -lz -lm -L#{szip}/lib -lsz -L#{opendap}/lib -ldap -ldapclient "+
        "-L#{curl}/lib -lcurl -lxml2 -lpthread -licucore -lstdc++",
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
      if PACKMAN.compiler_command('fortran') == 'gfortran'
        # Fix the wrong compiler flags.
        PACKMAN.replace "platform_specific.mk.#{build_type}", {
          /^(CPP_FLAGS\s*=.*)$/ => "\\1\n-DMANDATORY_FORMAT_WIDTHS -DNO_OPEN_SHARED -DNO_OPEN_READONLY "+
          "-DNO_OPEN_RECORDTYPE -DNO_OPEN_CARRIAGECONTROL -Dreclen_in_bytes -DG77_SIGNAL -DG77 -DNEED_IAND "+
          "-DINTERNAL_READ_FORMAT_BUG -DNO_PREPEND_STRING -Ddouble_p \\",
          /^\s*PPLUS_FFLAGS\s*=.*$/ => 'PPLUS_FFLAGS = -fno-automatic -fno-second-underscore '+
          '-fdollar-ok -ffixed-line-length-132 $(FINCLUDES)',
          /^\s*FFLAGS\s*=.*$/ => 'FFLAGS = -fno-automatic -fno-second-underscore -fdollar-ok '+
          '-ffixed-line-length-132 -ffpe-trap=overflow -fimplicit-none -fdefault-real-8 -fdefault-double-8 $(FINCLUDES)',
          /^(LD\s*=)/ => "PPLUS_FFLAGS += $(CPP_FLAGS)\nFFLAGS += $(CPP_FLAGS)\n\\1"
        }
      end
    else
      PACKMAN.replace 'site_specific.mk', {
        /^READLINE_DIR\s*=.*$/ => "READLINE_DIR = #{readline}"
      }
      PACKMAN.replace "platform_specific.mk.#{build_type}", {
        /^(\s*TERMCAPLIB\s*=).*$/ => "\\1 -L#{ncurses}/lib -lncurses"
      }
    end
    # Check if Xmu library is installed by system or not.
    if PACKMAN::OS.mac_gang?
      if not File.exist? '/usr/X11R6/include/X11/Xmu/WinUtil.h'
        PACKMAN::CLI.report_error "Mac does not install X11 (search Xquartz)."
      end
    else
      xmu_package = ''
      if PACKMAN::OS.redhat_gang?
        xmu_package = 'libXmu-devel'
      elsif PACKMAN::OS.debian_gang?
        xmu_package = 'libxmu-dev'
      end
      if not PACKMAN::OS.installed? xmu_package
        PACKMAN::CLI.report_warning "System package "+
          "#{PACKMAN::CLI.red xmu_package} is not "+
          "installed! Macro NO_WIN_UTIL_H will be used."
        PACKMAN::CLI.report_warning "If you want Ferret to use WIN_UTIL and you "+
          "have root previledge, you can install #{xmu_package} and come back."
        PACKMAN.replace "platform_specific.mk.#{build_type}", {
          /^(\s*CPP_FLAGS\s*=.*)$/ => "\\1\n-DNO_WIN_UTIL_H \\"
        }
      end
    end
    # Bad Ferret developers! Shame on you!
    if build_type == 'x86_64-darwin'
      File.open('xgks/CUSTOMIZE.x86_64-darwin', 'w') do |file|
        file << "CC=#{PACKMAN.compiler_command('c')}\n"
        file << "CFLAGS='#{PACKMAN.default_compiler_flags 'c'}'\n"
        file << "CPPFLAGS='-DNDEBUG'\n"
        file << "FC=#{PACKMAN.compiler_command('fortran')}\n"
        file << "FFLAGS='#{PACKMAN.default_compiler_flags 'fortran'}'\n"
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
    # Bad COMMON BLOCK usage.
    PACKMAN.replace 'external_functions/ef_utility/ferret_cmn/EF_mem_subsc_f90.inc', {
      /^\s*EXTERNAL\s*FERRET_EF_MEM_SUBSC\s*$/ => ''
    }
    PACKMAN.replace 'external_functions/ef_utility/ferret_cmn/EF_mem_subsc.cmn', {
      /^\s*EXTERNAL\s*FERRET_EF_MEM_SUBSC\s*$/ => ''
    }
    PACKMAN.replace 'fer/common/EF_mem_subsc.cmn', {
      /^\s*EXTERNAL\s*FERRET_EF_MEM_SUBSC\s*$/ => ''
    }
    if PACKMAN::OS.mac_gang?
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
        /\$\(NETCDF4_DIR\)\/lib\/libnetcdff\.a/ => "#{netcdf_fortran}/lib/libnetcdff.a",
        /^(\s*\$\(LIBZ_DIR\)\/lib\/libz.a)$/ => "\\1 \\\n#{szip}/lib/libsz.a"
      }
    end
    # BUILDTYPE is not propagated into external_functions directory
    ['contributed', 'examples', 'fft', 'statistics'].each do |dir|
      PACKMAN.replace "external_functions/#{dir}/Makefile", {
        /\$\(BUILDTYPE\)/ => build_type
      }
    end
    # Make.
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
    PACKMAN.cd ferret, :norecord
    PACKMAN.decompress 'fer_environment.tar.gz'
    PACKMAN.cd File.dirname(ferret), :norecord
    PACKMAN.mkdir 'datasets'
    PACKMAN.cd 'datasets', :norecord
    datasets = "#{PACKMAN::ConfigManager.package_root}/fer_dsets.tar.gz"
    PACKMAN.decompress datasets
    PACKMAN.cd ferret, :norecord
    # Do the final installation step.
    PACKMAN.rm 'ferret_paths.csh'
    PACKMAN.rm 'ferret_paths.sh'
    PTY.spawn('unset FER_DIR FER_DSETS; ./bin/Finstall') do |reader, writer, pid|
      reader.expect(/\(1, 2, 3, q, x\) --> /)
      writer.print("2\n")
      reader.expect(/FER_DIR --> /)
      writer.print("#{ferret}\n")
      reader.expect(/FER_DSETS --> /)
      writer.print("#{File.dirname(ferret)}/datasets\n")
      reader.expect(/desired ferret_paths location --> /)
      writer.print("#{ferret}\n")
      reader.expect(/ferret_paths link to create\? \(c\/s\/n\) \[n\] --> /)
      writer.print("n\n")
      reader.expect(/\(1, 2, 3, q, x\) --> /)
      writer.print("q\n")
    end
  end

  def postfix
    # Ferret has put its shell configuration into 'ferret_paths.sh', so we
    # respect it.
    bashrc = "#{PACKMAN.prefix(self)}/bashrc"
    PACKMAN.rm bashrc
    File.open(bashrc, 'w') do |file|
      file << "# #{sha1}\n"
      file << "source #{PACKMAN.prefix(self)}/ferret_paths.sh\n"
    end
  end
end
