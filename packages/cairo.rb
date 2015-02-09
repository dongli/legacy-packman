class Cairo < PACKMAN::Package
  url 'http://cairographics.org/releases/cairo-1.14.0.tar.xz'
  sha1 '53cf589b983412ea7f78feee2e1ba9cea6e3ebae'
  version '1.14.0'

  depends_on 'fontconfig'
  depends_on 'pixman'
  depends_on 'libpng'
  depends_on 'glib'
  depends_on 'x11'

  def install
    # https://www.libreoffice.org/bugzilla/show_bug.cgi?id=77060
    # http://gcc.gnu.org/onlinedocs/gccint/LTO.html
    # Disable LTO from GCC to avoid compilation failure. If use LTO,
    # then add 'ac_cv_prog_RANLIB=gcc-ranlib RANLIB="gcc-ranlib" AR="gcc-ar"' to args.
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --with-x
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
