class Imagemagick < PACKMAN::Package
  url 'http://www.imagemagick.org/download/ImageMagick-6.9.3-8.tar.bz2'
  sha1 'e614017cfe8ac119ccd29cc839e539fa2da94247'
  version '6.9.3-8'

  label :compiler_insensitive

  depends_on :libtool
  depends_on :zlib
  depends_on :fontconfig
  depends_on :freetype
  depends_on :jpeg
  depends_on :libtiff
  depends_on :libpng
  depends_on :x11
  depends_on :ghostscript
  depends_on :libwmf
  depends_on :librsvg
  depends_on :liblqr
  depends_on :openexr
  depends_on :fftw
  depends_on :pango
  depends_on :djvulibre
  depends_on :openjpeg
  depends_on :little_cms
  # depends_on 'webp' # WebP is hosted by Google, so we cannot access it within our great China!

  def install
    PACKMAN.handle_unlinked Freetype if PACKMAN.mac?
    PACKMAN.replace 'configure', { 'lcms2/lcms2.h' => 'lcms2.h' }
    PACKMAN.replace 'magick/profile.c', { 'lcms/lcms2.h' => 'lcms2.h' }
    PACKMAN.replace 'magick/property.c', {
      'lcms2/lcms2.h' => 'lcms2.h',
      'lcms/lcms.h' => 'lcms2.h',
      'lcms.h' => 'lcms2.h'
    }
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-shared
      --disable-static
      --with-modules
      --disable-openmp
      --with-zlib=yes
      --with-fontconfig=yes
      --with-freetype=yes
      --with-jpeg=yes
      --with-tiff=yes
      --with-png=yes
      --with-gslib=yes
      --with-gs-font-dir=#{link_root}/share/ghostscript/fonts
      --with-wmf=yes
      --with-rsvg=yes
      --with-lqr=yes
      --with-openexr=yes
      --with-fftw=yes
      --with-pango=yes
      --with-djvu=yes
      --with-openjp2=yes
      --with-lcms2=yes
    ]
    # --with-webp=#{Webp.prefix}
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
