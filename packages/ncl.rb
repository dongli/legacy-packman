require "pty"
require "expect"

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

  binary :Mac_OS_X, '10.9' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=382dd989-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 '36d82552f01e80fe82ab1687e361764dde5ccee7'
    version '6.2.1'
    filename 'ncl_ncarg-6.2.1.MacOS_10.9_64bit_gcc481.tar.gz'
  end

  binary :Ubuntu, '' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38263864-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 ''
    version '6.2.1'
    filename
  end

  binary :RedHat_Enterprise, '5' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38280d25-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 'd7e4a56c94b884801b7ee29af166c574636a9e94'
    version '6.2.1'
    filename 'ncl_ncarg-6.2.1.Linux_RHEL5.10_x86_64_gcc412.tar.gz'
  end

  binary [:RedHat_Enterprise, :Fedora, :CentOS], ['6', '', '6'] do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=38232b22-351d-11e4-a4b4-00c0f03d5b7c'
    sha1 '7f7980f944bd39192482d9260b9cbb619ce33a44'
    version '6.2.1'
    filename 'ncl_ncarg-6.2.1.Linux_RHEL6.4_x86_64_gcc472.tar.gz'
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
          "#{PACKMAN::Tty.red}idt#{PACKMAN::Tty.reset} tool, but it "+
          "is not installed by system! You can cancel to install it "+
          "with the following command if you really need "+
          "#{PACKMAN::Tty.red}idt#{PACKMAN::Tty.reset}.\n\n"+
          "--> #{PACKMAN::Tty.bold(PACKMAN::OS.how_to_install xaw_package)}"
      end
    end
    PACKMAN::RunManager.append_env "NCARG=#{PACKMAN::Package.prefix(self)}"
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
      writer.print("#{PACKMAN::Package.prefix(self)}\n")
      # System temp space directory?
      reader.expect(/Enter Return \(default\), new directory, or q\(quit\) >/)
      writer.print("#{PACKMAN::Package.prefix(self)}/tmp\n")
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
        if not Dir.exist? "#{PACKMAN::Package.prefix(lib)}/lib"
          writer.print "#{PACKMAN::Package.prefix(lib)}/lib "
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
        if not Dir.exist? "#{PACKMAN::Package.prefix(lib)}/include"
          writer.print "#{PACKMAN::Package.prefix(lib)}/include "
        end
      end
      if PACKMAN::OS.redhat_gang?
        writer.print "/usr/include/freetype2 "
      end
      writer.print "#{PACKMAN::Package.prefix(Gcc)}/include "
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
    PACKMAN.run "ls #{PACKMAN::Package.prefix(self)}/bin/ncl"
    # Create 'tmp' directory.
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/tmp"
    PACKMAN::RunManager.clean_env
  end

  def postfix
    if active_spec.has_label? 'binary'
      ncl = PACKMAN::Package.prefix self, :compiler_insensitive
    else
      ncl = PACKMAN::Package.prefix self
    end
    PACKMAN.replace "#{ncl}/bashrc", {
      /NCL_ROOT/ => 'NCARG_ROOT'
    }
  end
end
