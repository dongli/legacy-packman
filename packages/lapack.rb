# TODO: Try to use system BLAS.

class Lapack < PACKMAN::Package
  url 'http://www.netlib.org/lapack/lapack-3.6.0.tgz'
  sha1 '7e993de16d80d52b22b6093465eeb90c93c7a2e7'
  version '3.6.0'

  label :unlinked if PACKMAN.mac?

  depends_on :cmake

  option :with_static => false

  def install
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE="Release"
    ]
    args << "-DBUILD_SHARED_LIBS=ON" if not with_static?
    PACKMAN.run 'cmake', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end
