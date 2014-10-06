class Mlpack < PACKMAN::Package
  url 'http://www.mlpack.org/files/mlpack-1.0.9.tar.gz'
  sha1 '54e1958fc558b55625a7a52d2064420eb88c1ac1'
  version '1.0.9'

  depends_on 'cmake'
  depends_on 'armadillo'
  depends_on 'boost'
  depends_on 'libxml2'

  def install
    # Note: DBoost_NO_BOOST_CMAKE is set to ON to let CMake do the dirty job.
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{PACKMAN::Package.prefix(self)}
      -DCMAKE_BUILD_TYPE='Release'
      -DARMADILLO_INCLUDE_DIR=#{PACKMAN::Package.prefix(Armadillo)}/include
      -DARMADILLO_LIBRARY=#{PACKMAN::Package.prefix(Armadillo)}/lib/libarmadillo.#{PACKMAN::OS.shared_library_suffix}
      -DBoost_NO_BOOST_CMAKE=ON
      -DCMAKE_CXX_FLAGS='-I#{PACKMAN::Package.prefix(Hdf5)}/include'
      -DCMAKE_EXE_LINKER_FLAGS='-L#{PACKMAN::Package.prefix(Hdf5)}/lib'
    ]
    PACKMAN.mkdir 'build', :force do
      PACKMAN.run 'cmake ..', *args
      PACKMAN.run "make -j2"
      # PACKMAN.run 'make test'
      PACKMAN.run 'make install'
    end
  end
end
