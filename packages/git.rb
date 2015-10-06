class Git < PACKMAN::Package
  url 'https://github.com/git/git/archive/v2.4.0.tar.gz'
  sha1 'a5b5249b5946e600efb697b1f9adfe36d2810435'
  version '2.4.0'
  filename 'git-2.4.0.tar.gz'

  label :compiler_insensitive

  depends_on :zlib
  depends_on :expat
  depends_on :gettext
  depends_on :openssl
  depends_on :curl
  depends_on :pcre

  def install
    args = %W[
      prefix=#{prefix}
      sysconfdir=#{etc}
      NO_FINK=1
      NO_DARWIN_PORTS=1
      V=1
      NO_R_TO_GCC_LINKER=1
      BLK_SHA1=1
      NO_PERL=1
      GETTEXT=1
      CURLDIR=#{Curl.prefix}
      OPENSSLDIR=#{Openssl.prefix}
      ZLIB_PATH=#{Zlib_.prefix}
      USE_LIBPCRE=1
      LIBPCREDIR=#{Pcre.prefix}
      EXPATDIR=#{Expat.prefix}
      CC=${CC}
      CFLAGS="${CFLAGS}"
      CPPFLAGS="${CPPFLAGS}"
      LDFLAGS="${LDFLAGS} -lintl"
    ]
    PACKMAN.run 'make install', *args
  end
end
