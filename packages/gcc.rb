class Gcc < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2'
  sha1 'fe3f5390949d47054b613edc36c557eb1d51c18e'
  version '5.2.0'

  label :compiler_insensitive
  label :compiler_set

  depends_on :gmp
  depends_on :mpfr
  depends_on :mpc
  depends_on :isl

  provides :c => 'gcc'
  provides :cxx => 'g++'
  provides :fortran => 'gfortran'

  binary do
    compiled_on :Mac, '=~ 10.10'
    sha1 'bd3a058386b3a55ea7ddc04793d6ff995cb9be22'
    version '5.2.0'
  end

  def install
    languages = %W[c c++ fortran]
    args = %W[
      --prefix=#{prefix}
      --enable-languages=#{languages.join(',')}
      --with-gmp=#{Gmp.prefix}
      --with-mpfr=#{Mpfr.prefix}
      --with-mpc=#{Mpc.prefix}
      --with-isl=#{Isl.prefix}
      --enable-stage1-checking
      --enable-checking=release
      --enable-lto
      --disable-multilib
      --with-build-config=bootstrap-debug
      --disable-werror
    ]
    PACKMAN.mkdir 'build', :force do
      PACKMAN.run '../configure', *args
      rpath = PACKMAN.mac? ? link_root : "#{link_root}/lib"
      PACKMAN.replace 'Makefile', {
        /HOST_GMPLIBS\s*=(.*)/ => "HOST_GMPLIBS = -Wl,-rpath,#{rpath} \\1",
        /HOST_ISLLIBS\s*=(.*)/ => "HOST_ISLLIBS = -Wl,-rpath,#{rpath} \\1"
      }
      PACKMAN.run 'make -j2 bootstrap'
      PACKMAN.run 'make -j2 install'
    end
  end

  def repair_dynamic_link file, lib
    matched = lib.match(/lib(isl|mpc|mpfr|gmp)/)
    PACKMAN.os.add_rpath self, file, eval("#{matched[1].capitalize}.prefix") if matched
  end
end
