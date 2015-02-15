class Mlpack < PACKMAN::Package
  url 'http://www.mlpack.org/files/mlpack-1.0.10.tar.gz'
  sha1 '9c6f007007362a927ded79bd4835e266dbad4a77'
  version '1.0.10'

  depends_on 'cmake'
  depends_on 'armadillo'
  depends_on 'boost'
  depends_on 'libxml2'

  option 'use_cxx11' => true

  def install
    # Note: DBoost_NO_BOOST_CMAKE is set to ON to let CMake do the dirty job.
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE='Release'
      -DARMADILLO_INCLUDE_DIR=#{Armadillo.include}
      -DARMADILLO_LIBRARY=#{Armadillo.lib}/libarmadillo.#{PACKMAN::OS.shared_library_suffix}
      -DBoost_NO_BOOST_CMAKE=ON
      -DCMAKE_EXE_LINKER_FLAGS='-L#{Hdf5.lib}'
    ]
    if use_cxx11?
      args << "-DCMAKE_CXX_FLAGS='-I#{Hdf5.include} -std=c++11'"
    else
      args << "-DCMAKE_CXX_FLAGS='-I#{Hdf5.include}'"
    end
    PACKMAN.mkdir 'build', [:force, :silent] do
      PACKMAN.run 'cmake ..', *args
      PACKMAN.run 'make -j2'
      PACKMAN.run 'make test' if not skip_test?
      PACKMAN.run 'make install'
    end
  end
end
