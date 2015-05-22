class Flex < PACKMAN::Package
  url 'https://downloads.sourceforge.net/flex/flex-2.5.37.tar.bz2'
  sha1 'db4b140f2aff34c6197cab919828cc4146aae218'
  version '2.5.37'
  # NOTE: Failed to build 2.5.39.

  label :compiler_insensitive

  depends_on 'm4'
  depends_on 'libiconv'
  depends_on 'gettext'

  def install
    args = %W[
      --prefix=#{prefix}
      --with-libiconv-prefix=#{Libiconv.prefix}
      --with-libintl-prefix=#{Gettext.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
