class R < PACKMAN::Package
  url 'http://cran.rstudio.com/src/base/R-3/R-3.1.2.tar.gz'
  sha1 '93809368e5735a630611633ac1fa99010020c5d6'
  version '3.1.2'

  depends_on 'readline'
  depends_on 'gettext'
  depends_on 'libtiff'
  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'cairo'
  depends_on 'x11'
  depends_on 'openblas'

  # NOTE: We cannot access Google sites within our great LAN!!
  # attach do
  #   url 'https://rcompletion.googlecode.com/svn-history/r31/trunk/bash_completion/R'
  #   sha1 'ee39aa2de6319f41025cf8f618197d7efc16097c'
  # end

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --with-readline=#{PACKMAN.prefix Readline}
      --with-libintl-prefix=#{PACKMAN.prefix Gettext}
      --with-libtiff=#{PACKMAN.prefix Libtiff}
      --with-jpeglib=#{PACKMAN.prefix Jpeg}
      --with-libpng=#{PACKMAN.prefix Libpng}
      --with-cairo=#{PACKMAN.prefix Cairo}
      --with-blas=#{PACKMAN.prefix Openblas}
      --without-tcltk
    ]
    if PACKMAN::OS.type == :Darwin
      args << '--without-aqua'
    elsif PACKMAN::OS.type == :Linux
      args << '--enable-R-shlib'
    end
    PACKMAN::AutotoolHelper.set_cppflags_and_ldflags args, [Readline, Gettext]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check 2>&1 | tee make-check.log' if not skip_test?
    PACKMAN.run 'make install'
    if PACKMAN::OS.type == :Darwin
      prefix = PACKMAN.prefix self
      PACKMAN.ln "#{prefix}/R.framework/Resources/bin", prefix
      PACKMAN.ln "#{prefix}/R.framework/Resources/include", prefix
      PACKMAN.ln "#{prefix}/R.framework/Resources/lib/*", prefix+'/lib'
      PACKMAN.ln "#{prefix}/R.framework", prefix+'/Frameworks'
      PACKMAN.mkdir prefix+'/share/man', :silent
      PACKMAN.ln "#{prefix}/R.framework/Resources/man1", prefix+'/share/man'
    end
  end
end