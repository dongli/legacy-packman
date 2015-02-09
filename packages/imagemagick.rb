class Imagemagick < PACKMAN::Package
  url 'http://www.imagemagick.org/download/releases/ImageMagick-6.8.9-8.tar.xz'
  sha1 '5304855f3504994ff8bbf380e9a89a9e1dfe8834'
  version '6.8.9-8'

  label 'compiler_insensitive'

  depends_on 'libtool'
  depends_on 'zlib'
  depends_on 'fontconfig'
  depends_on 'freetype'
  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on 'libpng'
  depends_on 'little_cms'
  depends_on 'x11'
  depends_on 'ghostscript'
  depends_on 'libwmf'
  depends_on 'librsvg'
  depends_on 'liblqr'
  depends_on 'openexr'
  depends_on 'webp'
  depends_on 'fftw'
  depends_on 'pango'
  depends_on 'djvulibre'
  depends_on 'openjpeg'
  
  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --enable-shared
      --disable-static
      --with-modules
      --disable-openmp
      --with-zlib=#{PACKMAN.prefix Zlib}
      --with-fontconfig=#{PACKMAN.prefix Fontconfig}
      --with-freetype=#{PACKMAN.prefix Freetype}
      --with-jpeg=#{PACKMAN.prefix Jpeg}
      --with-tiff=#{PACKMAN.prefix Libtiff}
      --with-png=#{PACKMAN.prefix Libpng}
      --with-lcms2=#{PACKMAN.prefix Little_cms}
      --with-gslib=#{PACKMAN.prefix Ghostscript}
      --with-gs-font-dir=#{PACKMAN.prefix Ghostscript}/share/ghostscript/fonts
      --with-wmf=#{PACKMAN.prefix Libwmf}
      --with-rsvg=#{PACKMAN.prefix Librsvg}
      --with-lqr=#{PACKMAN.prefix Liblqr}
      --with-openexr=#{PACKMAN.prefix Openexr}
      --with-webp=#{PACKMAN.prefix Webp}
      --with-fftw=#{PACKMAN.prefix Fftw}
      --with-pango=#{PACKMAN.prefix Pango}
      --with-djvu=#{PACKMAN.prefix Djvulibre}
      --with-openjp2=#{PACKMAN.prefix Openjpeg}
    ]
    PACKMAN::AutotoolHelper.set_cppflags_and_ldflags args, [Libtool]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
