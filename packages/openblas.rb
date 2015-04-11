class Openblas < PACKMAN::Package
  url 'https://github.com/xianyi/OpenBLAS/archive/v0.2.11.zip'
  sha1 '533526327ec9a375387de0c18d5d7f5ea60e299b'
  version '0.2.11'

  def install
    args = []
    if PACKMAN.mac? and PACKMAN.compiler('c').vendor == 'gnu'
      # On Mac, only clang support AVX instructions, see http://trac.macports.org/ticket/40592.
      args << 'NO_AVX=1'
    end
    args << 'USE_OPENMP=1' if PACKMAN.all_compiler_support_openmp?
    PACKMAN.run 'make', *args
    PACKMAN.run "make install PREFIX=#{prefix}"
  end
end
