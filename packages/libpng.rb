class Libpng < PACKMAN::Package
  url 'http://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.14/libpng-1.6.14.tar.xz'
  sha1 '9cc30ac84214fda2177a02da275359ffd5b068d9'
  version '1.6.14'

  skip_on :Mac_OS_X

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --disable-silent-rules
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end

  def installed?
    File.exist? '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ImageIO.framework/Versions/A/Resources/libPng.dylib'
  end
end
