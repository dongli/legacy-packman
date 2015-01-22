class Gcc < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2'
  sha1 '3f303f403053f0ce79530dae832811ecef91197e'
  version '4.9.1'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'mpc'
  depends_on 'isl'
  depends_on 'cloog'

  label 'compiler_insensitive'
  provide 'c' => 'gcc'
  provide 'c++' => 'g++'
  provide 'fortran' => 'gfortran'

  if PACKMAN::OS.distro == :Mac_OS_X and PACKMAN::OS.version =~ '10.10'
    patch do
      url "https://raw.githubusercontent.com/DomT4/scripts/6c0e48921/Homebrew_Resources/Gcc/gcc1010.diff"
      sha1 "083ec884399218584aec76ab8f2a0db97c12a3ba"
    end
  end

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
