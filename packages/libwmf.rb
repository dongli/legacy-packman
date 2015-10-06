class Libwmf < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/wvware/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz'
  sha1 '822ab3bd0f5e8f39ad732f2774a8e9f18fc91e89'
  version '0.2.8.4'

  depends_on :expat
  depends_on :zlib
  depends_on :libgd
  depends_on :freetype
  depends_on :libpng
  depends_on :jpeg
  depends_on :ghostscript

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --with-expat=#{Expat.prefix}
      --with-zlib=#{Zlib.prefix}
      --with-sys-gd=#{Libgd.prefix}
      --with-png=#{Libpng.prefix}
      --with-freetype=#{Freetype.prefix}
      --with-jpeg=#{Jpeg.prefix}
      --with-gsfontdir=#{Ghostscript.share}/ghostscript/fonts
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
