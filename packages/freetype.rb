class Freetype < PACKMAN::Package
  url 'https://downloads.sf.net/project/freetype/freetype2/2.5.3/freetype-2.5.3.tar.bz2'
  sha1 'd3c26cc17ec7fe6c36f4efc02ef92ab6aa3f4b46'
  version '2.5.3'

  def install
    PACKMAN.replace('include/config/ftoption.h', /\/\* (#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING) \*\//, '\1')
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --without-harfbuzz
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end