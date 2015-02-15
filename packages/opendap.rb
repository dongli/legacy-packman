class Opendap < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/libdap-3.13.1.tar.gz'
  sha1 'fdfd5f311c920e9efb450e8ff82f42bc58197f23'
  version '3.13.1'

  depends_on 'uuid'
  depends_on 'curl'
  depends_on 'libxml2'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --with-curl=#{Curl.prefix}
      --with-xml2=#{Libxml2.prefix}
      --with-included-regex
      CPPFLAGS='-I#{Uuid.prefix}/include'
      LIBS='-L#{Uuid.prefix}/lib'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
