class Dos2unix < PACKMAN::Package
  url 'http://waterlan.home.xs4all.nl/dos2unix/dos2unix-7.2.tar.gz'
  sha1 'a8f3d048859acb5483c8e15a1dfd0a01a2bcabe0'
  version '7.2'

  label 'compiler_insensitive'

  depends_on 'gettext'

  def install
    args = %W[
      prefix=#{prefix}
      CFLAGS_OS='-I#{Gettext.include}'
      LDFLAGS_EXTRA='-L#{Gettext.lib} -lintl'
      install
    ]
    PACKMAN.run 'make', *args
  end
end