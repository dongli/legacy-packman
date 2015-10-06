class Mlpack < PACKMAN::Package
  url 'http://mlpack.org/files/mlpack-1.0.12.tar.gz'
  sha1 'ad4909e4978edf03ff70d5f3d884efb24b5992a4'
  version '1.0.12'

  depends_on :cmake
  depends_on :armadillo
  depends_on :boost
  depends_on :libxml2

  option :use_cxx11 => true

  def install
    # Note: DBoost_NO_BOOST_CMAKE is set to ON to let CMake do the dirty job.
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE='Release'
      -DARMADILLO_INCLUDE_DIR=#{Armadillo.include}
      -DARMADILLO_LIBRARY=#{Armadillo.lib}/libarmadillo.#{PACKMAN.shared_library_suffix}
      -DBoost_NO_BOOST_CMAKE=ON
      -DCMAKE_EXE_LINKER_FLAGS='-L#{Hdf5.lib}'
    ]
    if use_cxx11?
      args << "-DCMAKE_CXX_FLAGS='-I#{Hdf5.include} -std=c++11'"
    else
      args << "-DCMAKE_CXX_FLAGS='-I#{Hdf5.include}'"
    end
    PACKMAN.mkdir 'build', :force, :silent do
      PACKMAN.run 'cmake ..', *args
      PACKMAN.run 'make -j2'
      PACKMAN.run 'make test' if not skip_test?
      PACKMAN.run 'make install'
    end
  end
end
