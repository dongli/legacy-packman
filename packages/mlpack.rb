class Mlpack < PACKMAN::Package
  url 'http://www.mlpack.org/files/mlpack-1.0.9.tar.gz'
  sha1 '54e1958fc558b55625a7a52d2064420eb88c1ac1'
  version '1.0.9'

  depends_on 'cmake'
  depends_on 'armadillo'
  depends_on 'boost'
  depends_on 'libxml2'
  depends_on 'hdf5'

  def install
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{PACKMAN::Package.prefix(self)}
      -DCMAKE_BUILD_TYPE="Release"
      -DARMADILLO_INCLUDE_DIR=#{PACKMAN::Package.prefix(Armadillo)}/include
      -DARMADILLO_LIBRARY=#{PACKMAN::Package.prefix(Armadillo)}/lib/libarmadillo.#{PACKMAN::OS.shared_library_suffix}
      -DCMAKE_CXX_FLAGS='-I#{PACKMAN::Package.prefix(Hdf5)}/include'
    ]
    PACKMAN.mkdir 'build', true do
      PACKMAN.run 'cmake ..', *args
      PACKMAN.run "make -j2"
      PACKMAN.run 'make test'
      PACKMAN.run 'make install'
    end
  end
end
