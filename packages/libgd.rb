class Libgd < PACKMAN::Package
  url 'https://bitbucket.org/libgd/gd-libgd/downloads/libgd-2.1.0.tar.gz'
  sha1 'a0f3053724403aef9e126f4aa5c662573e5836cd'
  version '2.1.0'

  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'libtiff'
  depends_on 'fontconfig'
  depends_on 'freetype'
  # libvpx is not able to download, since it is stored in GoogleCode..

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --with-jpeg=#{PACKMAN.prefix Jpeg}
      --with-png=#{PACKMAN.prefix Libpng}
      --with-tiff=#{PACKMAN.prefix Libtiff}
      --with-fontconfig=#{PACKMAN.prefix Fontconfig}
      --with-freetype=#{PACKMAN.prefix Freetype}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end