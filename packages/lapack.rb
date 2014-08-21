class Lapack < PACKMAN::Package
  url 'http://www.netlib.org/lapack/lapack-3.5.0.tgz'
  sha1 '5870081889bf5d15fd977993daab29cf3c5ea970'
  version '3.5.0'

  depends_on 'cmake'

  def install
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{PACKMAN::Package.prefix(self)}
      -DCMAKE_BUILD_TYPE="Release"
    ]
    PACKMAN.run 'cmake', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make test'
    PACKMAN.run 'make install'
  end
end