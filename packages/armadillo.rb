class Armadillo < PACKMAN::Package
  url 'http://nchc.dl.sourceforge.net/project/arma/armadillo-4.650.4.tar.gz'
  sha1 '66525126e5b7d44d5f0b1689052e29ff662824a6'
  version '4.650.4'

  option 'use_mkl' => false

  depends_on 'cmake'
  if PACKMAN.linux? and not use_mkl?
    depends_on 'lapack'
    depends_on 'openblas'
  end
  depends_on 'arpack'
  depends_on 'hdf5'

  def install
    # The CMake find modules provided by Armadillo is so weak that
    # they can not find the dependent libraries just installed.
    if PACKMAN.linux? and not use_mkl?
      PACKMAN.replace 'cmake_aux/Modules/ARMA_FindLAPACK.cmake',
        /^  PATHS / => "  PATHS #{Lapack.lib} "
      PACKMAN.replace 'cmake_aux/Modules/ARMA_FindOpenBLAS.cmake',
        /^  PATHS / => "  PATHS #{Openblas.lib} "
    end
    PACKMAN.replace 'cmake_aux/Modules/ARMA_FindARPACK.cmake',
      /^  PATHS / => "  PATHS #{Arpack.lib} "
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
