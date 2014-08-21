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

  def install
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{PACKMAN::Package.prefix(self)}
      -DCMAKE_BUILD_TYPE="Release"
    ]
    PACKMAN.run 'cmake', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end