class Freetype < PACKMAN::Package
  url 'http://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.gz'
  sha1 '12dd3267af62cccc32045ed99984f3d8a8ddbf90'
  version '2.6'

  label :unlinked if PACKMAN.mac?

  depends_on :libpng
  depends_on :zlib
  depends_on :bzip2

  patch do
    url 'https://gist.githubusercontent.com/anonymous/b47d77c41a6801879fd2/raw/fc21c3516b465095da7ed13f98bea491a7d18bbd/patch'
    sha1 '01ff9947a977d639296c8bd2812cc899432f7284'
  end

  def install
    PACKMAN.handle_unlinked Libpng if PACKMAN.mac?
    PACKMAN.replace 'include/config/ftoption.h',
      /\/\* (#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING) \*\// => '\1'
    args = %W[
      --prefix=#{prefix}
      --with-png=#{Libpng.prefix}
      --with-zlib=#{link_root}
      --with-bzip2=#{link_root}
      --without-harfbuzz
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
