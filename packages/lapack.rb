# TODO: Try to use system BLAS.

class Lapack < PACKMAN::Package
  url 'http://www.netlib.org/lapack/lapack-3.5.0.tgz'
  sha1 '5870081889bf5d15fd977993daab29cf3c5ea970'
  version '3.5.0'

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
