class Libgd < PACKMAN::Package
  url 'https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.0.tar.gz'
  sha1 'a0f3053724403aef9e126f4aa5c662573e5836cd'
  version '2.1.0'

  depends_on :zlib
  depends_on :jpeg
  depends_on :libpng
  depends_on :libtiff
  depends_on :fontconfig
  depends_on :freetype
  # libvpx is not able to download, since it is stored in GoogleCode..

  def install
    PACKMAN.handle_unlinked Freetype if PACKMAN.mac?
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-zlib=#{link_root}
      --with-jpeg=#{Jpeg.prefix}
      --with-png=#{Libpng.prefix}
      --with-tiff=#{Libtiff.prefix}
      --with-fontconfig=#{link_root}
      --with-freetype=#{Freetype.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
