class Libpng < PACKMAN::Package
  url 'https://downloads.sf.net/project/libpng/libpng16/1.6.13/libpng-1.6.13.tar.xz'
  sha1 '5ae32b6b99cef6c5c85feab8edf9d619e1773b15'
  version '1.6.13'

  # skip_on :Mac_OS_X

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