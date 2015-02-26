class Webp < PACKMAN::Package
  url 'http://downloads.webmproject.org/releases/webp/libwebp-0.4.2.tar.gz'
  sha1 '49bb46fcb27aa01c7417064828560a57e3c7ff47'
  version '0.4.2'

  depends_on 'libpng'
  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on 'giflib'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-libwebpmux
      --enable-libwebpdemux
      --enable-libwebpdecoder
    ]
    PACKMAN.set_cppflags_and_ldflags [Libpng, Jpeg, Libtiff, Giflib]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
