class Libxslt < PACKMAN::Package
  url 'ftp://xmlsoft.org/libxml2/libxslt-1.1.28.tar.gz'
  sha1 '4df177de629b2653db322bfb891afa3c0d1fa221'
  version '1.1.28'

  depends_on :libxml2

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-libxml-prefix=#{Libxml2.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end