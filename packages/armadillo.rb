class Armadillo < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/arma/armadillo-4.300.3.tar.gz'
  sha1 '0decfda2f7cfa3c3dc534a7e7cc5d88e11794f70'
  version '4.300.3'

  option 'use_mkl' => false

  depends_on 'cmake'
  if PACKMAN::OS.type == :Linux and not use_mkl?
    depends_on 'lapack'
    depends_on 'openblas'
  end
  depends_on 'arpack'
  depends_on 'hdf5'

  def install
    # The CMake find modules provided by Armadillo is so weak that
    # they can not find the dependent libraries just installed.
    if PACKMAN::OS.type == :Linux and not use_mkl?
      PACKMAN.replace 'build_aux/cmake/Modules/ARMA_FindLAPACK.cmake',
        /^  PATHS / => "  PATHS #{PACKMAN.prefix(Lapack)}/lib "
      PACKMAN.replace 'build_aux/cmake/Modules/ARMA_FindOpenBLAS.cmake',
        /^  PATHS / => "  PATHS #{PACKMAN.prefix(Openblas)}/lib "
    end
    PACKMAN.replace 'build_aux/cmake/Modules/ARMA_FindARPACK.cmake',
      /^  PATHS / => "  PATHS #{PACKMAN.prefix(Arpack)}/lib "
    # In some cases, the MKL does not work as expected.
    if not use_mkl?
      PACKMAN.replace 'CMakeLists.txt', /(include\(ARMA_FindMKL\))/ => '#\1'
    end
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{PACKMAN.prefix(self)}
      -DCMAKE_BUILD_TYPE="Release"
    ]
    PACKMAN.run 'cmake', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
