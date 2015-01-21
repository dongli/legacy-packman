class Cairo < PACKMAN::Package
  url 'http://cairographics.org/releases/cairo-1.14.0.tar.xz'
  sha1 '53cf589b983412ea7f78feee2e1ba9cea6e3ebae'
  version '1.14.0'

  depends_on 'fontconfig'
  depends_on 'pixman'
  depends_on 'libpng'
  depends_on 'glib'
  depends_on 'x11'

  label 'use_system_first'

  def prefix
    installed? ? '/usr' : false
  end

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

  def installed?
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.installed? ['libcairo2', 'libcairo-dev']
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.installed? ['cairo', 'cairo-devel']
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.how_to_install ['libcairo2', 'libcairo-dev']
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.how_to_install ['cairo', 'cairo-devel']
    end
  end
end
