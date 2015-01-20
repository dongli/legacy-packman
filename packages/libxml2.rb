class Libxml2 < PACKMAN::Package
  url 'http://xmlsoft.org/sources/libxml2-2.9.1.tar.gz'
  sha1 'eb3e2146c6d68aea5c2a4422ed76fe196f933c21'
  version '2.9.1'

  depends_on 'zlib'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --without-python
      --with-zlib=#{PACKMAN.prefix Zlib}
      --without-lzma
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
