class Openblas < PACKMAN::Package
  url 'https://github.com/xianyi/OpenBLAS/archive/v0.2.11.zip'
  sha1 '5b31a71feaccb7898bff50de2db03808317d6348'
  version '0.2.11'
  filename 'openblas-0.2.11.zip'

  def install
    if PACKMAN.mac? and PACKMAN.os.version >= '10.5'
      PACKMAN.replace 'Makefile.system', {
        'export MACOSX_DEPLOYMENT_TARGET=10.2' => "export MACOSX_DEPLOYMENT_TARGET=#{PACKMAN.os.version}"
      }
    end
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
