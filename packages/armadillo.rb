class Armadillo < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/arma/armadillo-4.300.3.tar.gz'
  sha1 '0decfda2f7cfa3c3dc534a7e7cc5d88e11794f70'
  version '4.300.3'

  depends_on 'cmake'
  if PACKMAN::OS.type == :Linux
    depends_on 'lapack'
    depends_on 'openblas'
  end
  depends_on 'arpack'
  depends_on 'hdf5'

  def install
    if PACKMAN::OS.type == :Linux
      # The CMake find modules provided by Armadillo is so weak that
      # they can not find the Lapack and Openblas just installed
      PACKMAN.replace 'build_aux/cmake/Modules/ARMA_FindLAPACK.cmake',
        /^  PATHS / => "  PATHS #{PACKMAN.prefix(Lapack)}/lib "
      PACKMAN.replace 'build_aux/cmake/Modules/ARMA_FindOpenBLAS.cmake',
        /^  PATHS / => "  PATHS #{PACKMAN.prefix(Openblas)}/lib "
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
