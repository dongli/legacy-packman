class Libtiff < PACKMAN::Package
  url 'ftp://ftp.remotesensing.org/pub/libtiff/tiff-4.0.3.tar.gz'
  sha1 '652e97b78f1444237a82cbcfe014310e776eb6f0'
  version '4.0.3'

  label :not_set_ld_library_path if PACKMAN.mac?

  depends_on :jpeg

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --without-x
      --disable-lzma
      --with-jpeg-include-dir=#{Jpeg.prefix}/include
      --with-jpeg-lib-dir=#{Jpeg.prefix}/lib
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
