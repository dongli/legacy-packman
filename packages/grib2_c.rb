class Grib2_c < PACKMAN::Package
  url 'http://www.ncl.ucar.edu/Download/files/g2clib-1.5.0-patch.tar.gz'
  sha1 '3113b88e0295dbc64428edd87c0b583e774fb320'
  version '1.5.0'

  depends_on 'jasper'
  depends_on 'libpng'

  def install
    defs = 'DEFS=-DUSE_JPEG2000 -DUSE_PNG'
    defs << ' -D__64BIT__' if PACKMAN.os.x86_64?
    inc = "-I#{Jasper.include} -I#{Libpng.include}"
    PACKMAN.replace 'makefile', {
      /^DEFS=.*$/ => defs,
      /^(INC=.*)$/ => "\\1 #{inc}",
      /^CC=.*$/ => "CC=#{PACKMAN.compiler('c').command}",
    }
    PACKMAN.run 'make all'
    PACKMAN.mkdir include
    PACKMAN.cp 'grib2.h', include
    PACKMAN.mkdir lib
    PACKMAN.cp 'libgrib2c.a', lib
  end
end
