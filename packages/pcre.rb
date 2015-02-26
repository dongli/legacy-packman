class Pcre < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.bz2'
  sha1 '9a074e9cbf3eb9f05213fd9ca5bc188644845ccc'
  version '8.36'

  label 'compiler_insensitive'

  depends_on 'zlib'
  depends_on 'bzip2'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-utf8
      --enable-pcre8
      --enable-pcre16
      --enable-pcre32
      --enable-unicode-properties
      --enable-pcregrep-libz
      --enable-pcregrep-libbz2
      --enable-jit
    ]
    PACKMAN.set_cppflags_and_ldflags [Zlib, Bzip2]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end