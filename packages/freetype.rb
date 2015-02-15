class Freetype < PACKMAN::Package
  url 'http://download.savannah.gnu.org/releases/freetype/freetype-2.5.3.tar.gz'
  sha1 'd4a17b42505b23dab022f877e1849940aa3b64f3'
  version '2.5.3'

  depends_on 'libpng'
  depends_on 'zlib'
  depends_on 'bzip2'

  def install
    PACKMAN.replace 'include/config/ftoption.h',
      /\/\* (#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING) \*\// => '\1'
    args = %W[
      --prefix=#{prefix}
      --with-png=#{Libpng.prefix}
      --with-zlib=#{Zlib.prefix}
      --with-bzip2=#{Bzip2.prefix}
      --without-harfbuzz
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end