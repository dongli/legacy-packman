class Libpng < PACKMAN::Package
  url 'https://downloads.sf.net/project/libpng/libpng16/1.6.12/libpng-1.6.12.tar.gz'
  sha1 '6bcd6efa7f20ccee51e70453426d7f4aea7cf4bb'
  version '1.6.12'

  skip_on :Mac_OS_X

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
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