class Cloog < PACKMAN::Package
  url 'http://gcc.cybermirror.org/infrastructure/cloog-0.18.1.tar.gz'
  sha1 '2dc70313e8e2c6610b856d627bce9c9c3f848077'
  version '0.18.1'

  depends_on 'gmp'
  depends_on 'isl'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-silent-rules
      --with-gmp-prefix=#{PACKMAN::Package.prefix(Gmp)}
      --with-isl-prefix=#{PACKMAN::Package.prefix(Isl)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
