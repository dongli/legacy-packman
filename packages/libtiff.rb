class Libtiff < PACKMAN::Package
  url 'ftp://ftp.remotesensing.org/pub/libtiff/tiff-4.0.3.tar.gz'
  sha1 '652e97b78f1444237a82cbcfe014310e776eb6f0'
  version '4.0.3'

  depends_on 'jpeg'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --without-x
      --disable-lzma
      --with-jpeg-include-dir=#{PACKMAN.prefix Jpeg}/include
      --with-jpeg-lib-dir=#{PACKMAN.prefix Jpeg}/lib
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
