class Opendap < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/libdap-3.13.1.tar.gz'
  sha1 'fdfd5f311c920e9efb450e8ff82f42bc58197f23'
  version '3.13.1'

  depends_on 'uuid'
  depends_on 'curl'
  depends_on 'libxml2'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-debug
      --disable-dependency-tracking
      --with-curl=#{PACKMAN.prefix(Curl)}
      --with-xml2=#{PACKMAN.prefix(Libxml2)}
      --with-included-regex
      CPPFLAGS='-I#{PACKMAN.prefix(Uuid)}/include'
      LIBS='-L#{PACKMAN.prefix(Uuid)}/lib'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
