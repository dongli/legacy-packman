class Isl < PACKMAN::Package
  url 'http://isl.gforge.inria.fr/isl-0.12.2.tar.bz2'
  sha1 'ca98a91e35fb3ded10d080342065919764d6f928'
  version '0.12.2'

  depends_on 'gmp'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --disable-silent-rules
      --with-gmp-prefix=#{PACKMAN.prefix(Gmp)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end