class Openblas < PACKMAN::Package
  url 'https://github.com/xianyi/OpenBLAS/archive/v0.2.15.zip'
  sha1 '35a28d8ce03429e22a37ef142e4f491777609a0e'
  version '0.2.15'
  filename 'openblas-0.2.15.zip'

  def install
    args = []
    if PACKMAN.mac? and PACKMAN.compiler(:c).vendor == :gnu
      # On Mac, only clang support AVX instructions, see http://trac.macports.org/ticket/40592.
      args << 'NO_AVX=1'
    end
    args << 'USE_OPENMP=1' if PACKMAN.all_compiler_support_openmp?
    args << 'ONLY_CBLAS=1' if not PACKMAN.has_compiler? :fortran, :not_exit
    PACKMAN.run 'make', *args
    PACKMAN.run "make install PREFIX=#{prefix}"
  end
end
