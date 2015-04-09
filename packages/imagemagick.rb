class Imagemagick < PACKMAN::Package
  url 'http://www.imagemagick.org/download/releases/ImageMagick-6.9.1-1.tar.xz'
  sha1 '77e2dc47f87ec1c5b2cb519f298acf1f8202d7d8'
  version '6.9.1-1'

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
  # depends_on 'webp' # WebP is hosted by Google, so we cannot access it within our great China!
  depends_on 'fftw'
  depends_on 'pango'
  depends_on 'djvulibre'
  depends_on 'openjpeg'
  
  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-shared
      --disable-static
      --with-modules
      --disable-openmp
      --with-zlib=#{Zlib.prefix}
      --with-fontconfig=#{Fontconfig.prefix}
      --with-freetype=#{Freetype.prefix}
      --with-jpeg=#{Jpeg.prefix}
      --with-tiff=#{Libtiff.prefix}
      --with-png=#{Libpng.prefix}
      --with-lcms2=#{Little_cms.prefix}
      --with-gslib=#{Ghostscript.prefix}
      --with-gs-font-dir=#{Ghostscript.share}/ghostscript/fonts
      --with-wmf=#{Libwmf.prefix}
      --with-rsvg=#{Librsvg.prefix}
      --with-lqr=#{Liblqr.prefix}
      --with-openexr=#{Openexr.prefix}
      --with-fftw=#{Fftw.prefix}
      --with-pango=#{Pango.prefix}
      --with-djvu=#{Djvulibre.prefix}
      --with-openjp2=#{Openjpeg.prefix}
    ]
    # --with-webp=#{Webp.prefix}
    PACKMAN.set_cppflags_and_ldflags [Libtool]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
