class Gcc < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.9.2/gcc-4.9.2.tar.bz2'
  sha1 '79dbcb09f44232822460d80b033c962c0237c6d8'
  version '4.9.2'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'mpc'
  depends_on 'isl'
  depends_on 'cloog'

  label :compiler_insensitive
  provide 'c' => 'gcc'
  provide 'c++' => 'g++'
  provide 'fortran' => 'gfortran'

  def install
    if PACKMAN.mac?
      languages = %W[c c++ objc fortran]
    else
      languages = %W[c c++ fortran]
    end
    args = %W[
      --prefix=#{prefix}
      --enable-languages=#{languages.join(',')}
      --with-gmp=#{Gmp.prefix}
      --with-mpfr=#{Mpfr.prefix}
      --with-mpc=#{Mpc.prefix}
      --with-cloog=#{Cloog.prefix}
      --with-isl=#{Isl.prefix}
      --disable-multilib
      --with-build-config=bootstrap-debug
      --disable-werror
    ]
    PACKMAN.mkdir 'build', :force do
      PACKMAN.run '../configure', *args
      PACKMAN.run 'make -j2 bootstrap'
      PACKMAN.run 'make -j2 install'
    end
  end

  def post_install
    # NOTE: It seems that GCC_ROOT environment variable must not be set.
    # Otherwise, the system GCC will be disturbed!
    PACKMAN.replace "#{PACKMAN.prefix self}/bashrc", {
      /export GCC_ROOT=.*$/ => '',
      /\$\{GCC_ROOT\}/ => "#{PACKMAN.prefix self}"
    }
    # Source the dependent packages in the Gcc bashrc so that Gcc can find
    # those package when doing dynamic loading.
    PACKMAN.append "#{PACKMAN.prefix self}/bashrc",
      ". #{PACKMAN.prefix(Gmp)}/bashrc\n"+
      ". #{PACKMAN.prefix(Mpfr)}/bashrc\n"+
      ". #{PACKMAN.prefix(Mpc)}/bashrc\n"+
      ". #{PACKMAN.prefix(Isl)}/bashrc\n"+
      ". #{PACKMAN.prefix(Cloog)}/bashrc\n"
  end
end
