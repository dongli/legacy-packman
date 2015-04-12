class Git < PACKMAN::Package
  url 'https://www.kernel.org/pub/software/scm/git/git-2.3.5.tar.xz'
  sha1 'a74f0f097a1893f9275b501ae515db2d08422550'
  version '2.3.5'

  label 'compiler_insensitive'

  depends_on 'gettext'
  depends_on 'openssl'
  depends_on 'curl'
  depends_on 'pcre'

  def install
    args = %W[
      prefix=#{prefix}
      sysconfdir=#{etc}
      NO_FINK=1
      NO_DARWIN_PORTS=1
      V=1
      NO_R_TO_GCC_LINKER=1
      BLK_SHA1=1
      GETTEXT=1
      USE_LIBPCRE=1
      LIBPCRE=#{Pcre.prefix}
      CC=${CC}
      CFLAGS="${CFLAGS}"
      CPPFLAGS="${CPPFLAGS}"
      LDFLAGS="${LDFLAGS} -lintl"
    ]
    PACKMAN.set_cppflags_and_ldflags [Gettext, Openssl, Curl]
    PACKMAN.run 'make install', *args

  end
end