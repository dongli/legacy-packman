class Imagemagick < PACKMAN::Package
  url 'http://www.imagemagick.org/download/releases/ImageMagick-6.8.9-8.tar.xz'
  sha1 '5304855f3504994ff8bbf380e9a89a9e1dfe8834'
  version '6.8.9-8'

  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on 'libpng'
  depends_on 'little_cms'
  depends_on 'x11'
  depends_on 'ghostscript'
  depends_on 'libwmf'
  # depends_on 'librsvg'
  depends_on 'fontconfig'
  depends_on 'freetype'
  
  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --enable-shared
      --disable-static
      --without-pango
      --with-modules
      --disable-openmp
      --with-jpeg=#{PACKMAN.prefix Jpeg}
      --with-tiff=#{PACKMAN.prefix Libtiff}
      --with-png=#{PACKMAN.prefix Libpng}
      --with-lcms2=#{PACKMAN.prefix Little_cms}
      --with-gslib=#{PACKMAN.prefix Ghostscript}
      --with-gs-font-dir=#{PACKMAN.prefix Ghostscript}/share/ghostscript/fonts
      --with-wmf=#{PACKMAN.prefix Libwmf}
      --with-fontconfig=#{PACKMAN.prefix Fontconfig}
      --with-freetype=#{PACKMAN.prefix Freetype}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end