class Opendap < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/libdap-3.14.0.tar.gz'
  sha1 'a95c345da2164ec7a790b34b7f0aeb9227277770'
  version '3.14.0'

  depends_on 'bison'
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
