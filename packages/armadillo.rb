class Armadillo < PACKMAN::Package
  url 'http://sourceforge.net/projects/arma/files/armadillo-5.000.1.tar.gz'
  sha1 '817bc80a5d469afba1c53a73160e7ca6fe0782ad'
  version '5.000.1'

  option :use_mkl => false

  depends_on :cmake
  if PACKMAN.linux? and not use_mkl?
    depends_on :lapack
    depends_on :openblas
  end
  depends_on :arpack
  depends_on :hdf5
  depends_on :superlu

  def install
    # The CMake find modules provided by Armadillo is so weak that
    # they can not find the dependent libraries just installed.
    if PACKMAN.linux? and not use_mkl?
      PACKMAN.replace 'cmake_aux/Modules/ARMA_FindLAPACK.cmake',
        /^\s*PATHS / => "  PATHS #{Lapack.lib} "
      PACKMAN.replace 'cmake_aux/Modules/ARMA_FindOpenBLAS.cmake',
        /^\s*PATHS / => "  PATHS #{Openblas.lib} "
    end
    PACKMAN.replace 'cmake_aux/Modules/ARMA_FindARPACK.cmake',
      /^\s*PATHS / => "  PATHS #{Arpack.lib} "
    PACKMAN.replace 'cmake_aux/Modules/ARMA_FindSuperLU.cmake', {
      'SET(SuperLU_FOUND NO)' =>
        "SET (SuperLU_INCLUDE_DIR #{Superlu.inc}/superlu)\n"+
        "SET (SuperLU_LIBRARY #{Superlu.lib}/libsuperlu.a)"
    }
    # In some cases, the MKL does not work as expected.
    if not use_mkl?
      PACKMAN.replace 'CMakeLists.txt', /(include\(ARMA_FindMKL\))/ => '#\1'
    end
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE="Release"
    ]
    PACKMAN.run 'cmake', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
