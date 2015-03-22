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

  history_binary_version '6.2.1', :Mac_OS_X, '>= 10.9' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=382dd989-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 '36d82552f01e80fe82ab1687e361764dde5ccee7'
    filename 'ncl_ncarg-6.2.1.MacOS_10.9_64bit_gcc481.tar.gz'
  end

  history_binary_version '6.2.1', [:Debian, :Ubuntu], ['>= 7.6', '>= 12.04'] do
    if PACKMAN::OS.x86_64?
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38263864-351d-11e4-a4b4-00c0f03d5b7c'
      sha1 'b7c885391891cb5709c44df3314391787c3ed9c3'
      filename 'ncl_ncarg-6.2.1.Linux_Debian7.6_x86_64_gcc472.tar.gz'
    else
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=382af357-351d-11e4-a4b4-00c0f03d5b7c'
      sha1 '2330bccc6ac34f652c30a9d35d9c1579e9187469'
      filename 'ncl_ncarg-6.2.1.Linux_Debian6.0_i686_gcc445.tar.gz'
    end
  end

  history_binary_version '6.2.1', :RHEL, '=~ 5' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38280d25-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 'd7e4a56c94b884801b7ee29af166c574636a9e94'
    filename 'ncl_ncarg-6.2.1.Linux_RHEL5.10_x86_64_gcc412.tar.gz'
  end

  history_binary_version '6.2.1', [:RHEL, :Fedora, :CentOS], ['=~ 6', '>= 14', '>= 6'] do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38232b22-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 '7f7980f944bd39192482d9260b9cbb619ce33a44'
    filename 'ncl_ncarg-6.2.1.Linux_RHEL6.4_x86_64_gcc472.tar.gz'
  end

  history_binary_version '6.2.1', :Cygwin, '6.1' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=381d109f-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 'f9eac2f4289ce04d68ca7f9ff4bfdaa08382e4b6'
    filename 'ncl_ncarg-6.2.1.CYGWIN_NT-6.1-WOW64_i686.tar.gz'
  end

  binary [:Debian, :Ubuntu], ['>= 6.0', '>= 12.04'] do
    if PACKMAN::OS.x86_64?
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e088d94c-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '32b0c6192992910e26f7fd19b04e05a7d97fed10'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_Debian6.0_x86_64_gcc445.tar.gz'
    else
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0894e7d-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '662d22d0f915c6b2378dea902a8f9acfd1dee761'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_Debian6.0_i686_gcc445.tar.gz'
    end
  end

  binary :Debian, '>= 7.8' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e087c7da-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 'c0cbc8f6a813489e04fb91aa79a593bf0b614540'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.Linux_Debian7.8_x86_64_gcc472.tar.gz'
  end

  binary :Mac_OS_X, '=~ 10.10' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e085cc06-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 'b4b5ff0a760ef54c62720f1e4340227eea9a795d'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.MacOS_10.10_64bit_gcc492.tar.gz'
  end

  binary :Mac_OS_X, '=~ 10.9' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0849384-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '431758706a90bb28ffa068df6c73e5402ea7c031'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.MacOS_10.9_64bit_gcc492.tar.gz'
  end

  binary :Mac_OS_X, '=~ 10.8' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0852fc5-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '3528629ecc6930a6bb4bcdfe12e825ef08723db3'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.MacOS_10.8_64bit_gcc471.tar.gz'
  end

  binary :RHEL, '=~ 5' do
    if PACKMAN::OS.x86_64?
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0883d0b-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '379b2f31b4e5fd588c8e118b03a74bd284bccdb2'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_RHEL5.11_x86_64_gcc412.tar.gz'
    else
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e08a11ce-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '74baba69aa0a03861093fe5d6305fad09623552d'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_RHEL5.11_i686_gcc412.tar.gz'
    end
  end

  binary [:RHEL, :Fedora, :CentOS], ['=~ 6', '>= 14', '>= 6'] do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0866847-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 'c33f853e29867c4c234ae66928e7e34782d4ad1c'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.Linux_RHEL6.4_x86_64_gcc472.tar.gz'
  end

  binary :CentOS, '7' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e083a923-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '034f9df8d34553fd309fbdaec878cebf6bbc9d8b'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.Linux_CentOS7.0_x86_64_gcc482.tar.gz'
  end

  binary :Cygwin, '6.1' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e08a86ff-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '1fc92ef0b47c77d07b9ce6f51fbb75e0039bed40'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.CYGWIN_NT-6.1-WOW64_i686.tar.gz'
  end

  # TODO: Maintain the compilation of NCL from source codes!
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
    PACKMAN.replace bashrc, {
      /NCL_ROOT/ => 'NCARG_ROOT'
    }
  end
end
