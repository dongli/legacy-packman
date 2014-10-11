class Gcc < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2'
  sha1 '3f303f403053f0ce79530dae832811ecef91197e'
  version '4.9.1'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'mpc'
  depends_on 'isl'
  depends_on 'cloog'

  label 'compiler'
  provide 'c' => 'gcc'
  provide 'c++' => 'g++'
  provide 'fortran' => 'gfortran'

  def install
    if PACKMAN::OS.mac_gang?
      languages = %W[c c++ objc fortran]
    else
      languages = %W[c c++ fortran]
    end
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --enable-languages=#{languages.join(',')}
      --with-gmp=#{PACKMAN.prefix(Gmp)}
      --with-mpfr=#{PACKMAN.prefix(Mpfr)}
      --with-mpc=#{PACKMAN.prefix(Mpc)}
      --with-cloog=#{PACKMAN.prefix(Cloog)}
      --with-isl=#{PACKMAN.prefix(Isl)}
      --disable-multilib
    ]
    PACKMAN.mkdir 'build', :force do
      PACKMAN.run '../configure', *args
      PACKMAN.run 'make -j2 bootstrap'
      PACKMAN.run 'make -j2 install'
    end
  end

  def postfix
    # Source the dependent packages in the Gcc bashrc so that Gcc can find
    # those package when doing dynamic loading.
    PACKMAN.append "#{PACKMAN.prefix(self)}/bashrc",
      ". #{PACKMAN.prefix(Gmp)}/bashrc\n"+
      ". #{PACKMAN.prefix(Mpfr)}/bashrc\n"+
      ". #{PACKMAN.prefix(Mpc)}/bashrc\n"+
      ". #{PACKMAN.prefix(Isl)}/bashrc\n"+
      ". #{PACKMAN.prefix(Cloog)}/bashrc\n"
  end
end
