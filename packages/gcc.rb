class Gcc < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2'
  sha1 'fe3f5390949d47054b613edc36c557eb1d51c18e'
  version '5.2.0'

  history_version '4.9.2' do
    # FIXME: Use more elegant method to handle compiler package version change.
  end

  label :compiler_insensitive
  label :compiler_set

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'mpc'
  depends_on 'isl'

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
end
