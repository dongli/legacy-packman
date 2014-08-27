class Grib2_c < PACKMAN::Package
  url 'http://www.ncl.ucar.edu/Download/files/g2clib-1.5.0-patch.tar.gz'
  sha1 '3113b88e0295dbc64428edd87c0b583e774fb320'
  version '1.5.0'

  depends_on 'jasper'
  depends_on 'libpng'

  def install
    defs = 'DEFS=-DUSE_JPEG2000 -DUSE_PNG'
    defs << ' -D__64BIT__' if PACKMAN::OS.x86_64?
    inc = "-I#{PACKMAN::Package.prefix(Jasper)}/include"
    inc << " -I#{PACKMAN::Package.prefix(Libpng)}/include" if not PACKMAN::OS.distro == :Mac_OS_X
    PACKMAN.replace 'makefile', {
      /^DEFS=.*$/ => defs,
      /^(INC=.*)$/ => "\\1 #{inc}",
      /^CC=.*$/ => "CC=#{PACKMAN.compiler_command 'c'}",
    }
    PACKMAN.run 'make all'
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/include"
    PACKMAN.cp 'grib2.h', "#{PACKMAN::Package.prefix(self)}/include"
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/lib"
    PACKMAN.cp 'libgrib2c.a', "#{PACKMAN::Package.prefix(self)}/lib"
  end
end
