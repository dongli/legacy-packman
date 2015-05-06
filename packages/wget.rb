class Wget < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/wget/wget-1.16.1.tar.xz'
  sha1 '21cd7eee08ab5e5a14fccde22a7aec55b5fcd6fc'
  version '1.16.1'

  label 'compiler_insensitive'

  depends_on 'openssl'
  depends_on 'libidn'
  depends_on 'pcre'

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-ssl=openssl
      --with-libssl-prefix=#{Openssl.prefix}
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
