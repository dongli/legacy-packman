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
  # attach 'bash_completion' do
  #   url 'https://rcompletion.googlecode.com/svn-history/r31/trunk/bash_completion/R'
  #   sha1 'ee39aa2de6319f41025cf8f618197d7efc16097c'
  # end

  def install
    args = %W[
      --prefix=#{prefix}
      --with-readline=#{Readline_.prefix}
      --with-libintl-prefix=#{Gettext.prefix}
      --with-libtiff=#{Libtiff.prefix}
      --with-jpeglib=#{Jpeg.prefix}
      --with-libpng=#{Libpng.prefix}
      --with-cairo=#{Cairo.prefix}
      --with-blas=#{Openblas.prefix}
      --without-tcltk
    ]
    if PACKMAN.mac?
      args << '--without-aqua'
    elsif PACKMAN.linux?
      args << '--enable-R-shlib'
    end
    PACKMAN.set_cppflags_and_ldflags [Readline_, Gettext]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check 2>&1 | tee make-check.log' if not skip_test?
    PACKMAN.run 'make install'
    if PACKMAN.mac?
      PACKMAN.mkdir bin, :silent
      ['R', 'Rscript'].each do |cmd|
        PACKMAN.ln "#{prefix}/R.framework/Resources/bin/#{cmd}", bin
      end
      PACKMAN.mkdir include, :silent
      PACKMAN.ln "#{prefix}/R.framework/Resources/include/R.h", include
      PACKMAN.ln "#{prefix}/R.framework/Resources/lib/libR.dylib", lib
      PACKMAN.ln "#{prefix}/R.framework", prefix+'/Frameworks'
      PACKMAN.mkdir man, :silent
      ['R.1', 'Rscript.1'].each do |mpg|
        PACKMAN.ln "#{prefix}/R.framework/Resources/man1/#{mpg}", man
      end
    end
  end
end