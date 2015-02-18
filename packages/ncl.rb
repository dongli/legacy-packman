class Ncl < PACKMAN::Package
  url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=474bb254-ba75-11e3-b322-00c0f03d5b7c'
  sha1 '9f7be65e0406a410b27d338309315deac2e64b6c'
  filename 'ncl_ncarg-6.2.0.tar.gz'
  version '6.2.0'

  depends_on 'expat'
  depends_on 'freetype'
  depends_on 'fontconfig'
  depends_on 'szip'
  depends_on 'jasper'
  depends_on 'libpng'
  depends_on 'cairo'
  depends_on 'jpeg'
  depends_on 'hdf4'
  depends_on 'netcdf_c'
  depends_on 'netcdf_fortran'
  depends_on 'hdf_eos2'
  depends_on 'hdf_eos5'
  depends_on 'grib2_c'
  depends_on 'gdal'
  depends_on 'proj'
  depends_on 'triangle'
  depends_on 'udunits'
  depends_on 'vis5dx'

  label 'compiler_insensitive'

  history_binary_version '6.2.0', :Mac_OS_X, '>= 10.9' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=24ac2346-ba14-11e3-b322-00c0f03d5b7c'
    sha1 '2b7b1ce44b494d10a57ddce0e9405af53a9062d0'
    filename 'ncl_ncarg-6.2.0.MacOS_10.9_64bit_gcc481.tar.gz'
  end

  history_binary_version '6.2.0', [:Debian, :Ubuntu], ['>= 7.4', '>= 12.04'] do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=5c76fcc2-ba18-11e3-b322-00c0f03d5b7c'
    sha1 'c0b7252c6fd74cc0c5d415f68f37106ce520c7c2'
    filename 'ncl_ncarg-6.2.0.Linux_Debian7.4_x86_64_gcc472.tar.gz'
  end

  history_binary_version '6.2.0', :RHEL, '=~ 5' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=5c732c30-ba18-11e3-b322-00c0f03d5b7c'
    sha1 '2f9644c4ce8744cb75fb908ac9715b621ca6b476'
    filename 'ncl_ncarg-6.2.0.Linux_RHEL5.10_x86_64_gcc412.tar.gz'
  end

  history_binary_version '6.2.0', [:RHEL, :Fedora, :CentOS], ['=~ 6', '=~ 14', '=~ 6'] do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=24b0690a-ba14-11e3-b322-00c0f03d5b7c'
    sha1 '4737c15e454f912e7f677f15cd261ebd324b10ab'
    filename 'ncl_ncarg-6.2.0.Linux_RHEL6.2_x86_64_gcc446.tar.gz'
  end

  binary :Mac_OS_X, '>= 10.9' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=382dd989-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 '36d82552f01e80fe82ab1687e361764dde5ccee7'
    version '6.2.1'
    filename 'ncl_ncarg-6.2.1.MacOS_10.9_64bit_gcc481.tar.gz'
  end

  binary [:Debian, :Ubuntu], ['>= 7.6', '>= 12.04'] do
    if PACKMAN::OS.x86_64?
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38263864-351d-11e4-a4b4-00c0f03d5b7c'
      sha1 'b7c885391891cb5709c44df3314391787c3ed9c3'
      filename 'ncl_ncarg-6.2.1.Linux_Debian7.6_x86_64_gcc472.tar.gz'
    else
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=382af357-351d-11e4-a4b4-00c0f03d5b7c'
      sha1 '2330bccc6ac34f652c30a9d35d9c1579e9187469'
      filename 'ncl_ncarg-6.2.1.Linux_Debian6.0_i686_gcc445.tar.gz'
    end
    version '6.2.1'
  end

  binary :RHEL, '=~ 5' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38280d25-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 'd7e4a56c94b884801b7ee29af166c574636a9e94'
    version '6.2.1'
    filename 'ncl_ncarg-6.2.1.Linux_RHEL5.10_x86_64_gcc412.tar.gz'
  end

  binary [:RHEL, :Fedora, :CentOS], ['=~ 6', '>= 14', '>= 6'] do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38232b22-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 '7f7980f944bd39192482d9260b9cbb619ce33a44'
    version '6.2.1'
    filename 'ncl_ncarg-6.2.1.Linux_RHEL6.4_x86_64_gcc472.tar.gz'
  end

  binary :Cygwin, '6.1' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=381d109f-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 'f9eac2f4289ce04d68ca7f9ff4bfdaa08382e4b6'
    version '6.2.1'
    filename 'ncl_ncarg-6.2.1.CYGWIN_NT-6.1-WOW64_i686.tar.gz'
  end

  def install
    # Check some system packages.
    if not PACKMAN::OS.mac_gang?
      if PACKMAN::OS.redhat_gang?
        xaw_package = 'libXaw-devel'
      elsif PACKMAN::OS.debian_gang?
        xaw_package = ['libxt-dev', 'libxaw-headers']
      end
      if not PACKMAN::OS.installed? xaw_package
        PACKMAN.report_warning "NCL needs Xaw (its headers) to build "+
          "#{PACKMAN.red 'idt'}, but it is not installed by system! "+
          "You can cancel to install it with the following command if you "+
          "really need #{PACKMAN.red 'idt'}.\n\n"+
          "#{PACKMAN.yellow '==>'} #{PACKMAN::OS.how_to_install xaw_package}"
      end
    end
    PACKMAN.append_env 'NCARG', prefix
    # Copy Triangle codes into necessary place.
    PACKMAN.mkdir 'triangle'
    PACKMAN.cd 'triangle'
    PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/triangle.zip"
    PACKMAN.cp 'triangle.h', '../ni/src/lib/hlu'
    PACKMAN.cp 'triangle.c', '../ni/src/lib/hlu'
    PACKMAN.cd_back
    # Check if system is supported by NCL.
    PACKMAN.cd 'config'
    PACKMAN.run 'make -f Makefile.ini'
    res ='./ymake -config `pwd`'
    if res == 'ymake: system unknown'
      PACKMAN.report_error "Current system is not supported by NCL!"
    end
    PACKMAN.cd_back
    # Configure NCL.
    # COMPLAIN: NCL should use more canonical method (e.g. Autoconf or CMake) to
    #           do configuration work!
    PTY.spawn('./Configure -v') do |reader, writer, pid|
      reader.expect(/Enter Return to continue, or q\(quit\) > /)
      writer.print("\n")
      reader.expect(/Enter Return to continue, or q\(quit\) > /)
      writer.print("\n")
      # Build NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Parent installation directory?
      reader.expect(/Enter Return \(default\), new directory, or q\(quit\) >/)
      writer.print("#{prefix}\n")
      # System temp space directory?
      reader.expect(/Enter Return \(default\), new directory, or q\(quit\) >/)
      writer.print("#{prefix}/tmp\n")
      # Build NetCDF4 feature support (optional)?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build HDF4 support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Also build HDF4 support (optional) into raster library?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Did you build HDF4 with szip support?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build Triangle support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # If you are using NetCDF V4.x, did you enable NetCDF-4 support?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Did you build NetCDF with OPeNDAP support (y)?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build GDAL support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build Udunits-2 support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build Vis5d+ support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build HDF-EOS2 support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build HDF5 support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build HDF-EOS5 support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Build GRIB2 support (optional) into NCL?
      reader.expect(/Enter Return \(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print("y\n")
      # Enter local library search path(s).
      reader.expect(/Enter Return \(default\), new directories, or q\(quit\) > /)
      if PACKMAN::OS.distro == :Mac_OS_X
        writer.print "/usr/X11R6/lib "
      end
      [ Expat, Freetype, Fontconfig, Szip, Jasper, Cairo, Jpeg, Libpng, Hdf4, Hdf5,
        Netcdf_c, Netcdf_fortran, Pixman, Hdf_eos2, Hdf_eos5, Grib2_c, Gdal, Proj,
      Udunits, Vis5dx ].each do |lib|
        if not Dir.exist? "#{lib.lib}"
          writer.print "#{lib.lib} "
        end
      end
      writer.print "\n"
      # Enter local include search path(s).
      reader.expect(/Enter Return \(default\), new directories, or q\(quit\) > /)
      if PACKMAN::OS.distro == :Mac_OS_X
        writer.print "/usr/X11R6/include "
      end
      [ Expat, Freetype, Fontconfig, Szip, Jasper, Cairo, Jpeg, Libpng, Hdf4, Hdf5,
        Netcdf_c, Netcdf_fortran, Pixman, Hdf_eos2, Hdf_eos5, Grib2_c, Gdal, Proj,
      Udunits, Vis5dx ].each do |lib|
        if not Dir.exist? "#{lib.include}"
          writer.print "#{lib.include} "
        end
      end
      if PACKMAN::OS.redhat_gang?
        writer.print "/usr/include/freetype2 "
      end
      writer.print "#{Gcc.include} "
      writer.print "\n"
      # Go back and make more changes or review?
      reader.expect(/Enter Return\(default\), y\(yes\), n\(no\), or q\(quit\) > /)
      writer.print "n\n"
      # Save current configuration?
      reader.expect(/Enter Return\(default\), y\(yes\), or q\(quit\) > /)
      writer.print "y\n"
      reader.expect(/make Everything/)
    end
    # Make NCL.
    PACKMAN.run 'make Everything'
    # Make sure command 'ncl' is built.
    PACKMAN.run "ls #{bin}/ncl"
    # Create 'tmp' directory.
    PACKMAN.mkdir "#{prefix}/tmp"
  end

  def postfix
    if has_label? 'binary'
      ncl = PACKMAN.prefix self, :compiler_insensitive
    else
      ncl = PACKMAN.prefix self
    end
    PACKMAN.replace "#{ncl}/bashrc", {
      /NCL_ROOT/ => 'NCARG_ROOT'
    }
  end
end
