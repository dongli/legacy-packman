class Cairo < PACKMAN::Package
  url 'http://cairographics.org/releases/cairo-1.14.0.tar.xz'
  sha1 '53cf589b983412ea7f78feee2e1ba9cea6e3ebae'
  version '1.14.0'

  depends_on 'zlib'
  depends_on 'fontconfig'
  depends_on 'pixman'
  depends_on 'libpng'
  depends_on 'glib'
  depends_on 'x11'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-x
    ]
    if PACKMAN.mac?
      PACKMAN.replace 'configure', /^\s*use_png=no$/ => 'use_png=yes'
      args << "CPPFLAGS='-I#{Libpng.include}'"
      args << "LDFLAGS='-L#{Libpng.lib} -lpng'"
    end
    PACKMAN.set_cppflags_and_ldflags [Zlib]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
