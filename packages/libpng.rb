class Libpng < PACKMAN::Package
  url 'http://downloads.sf.net/project/libpng/libpng16/1.6.16/libpng-1.6.16.tar.xz'
  sha1 '31855a8438ae795d249574b0da15b34eb0922e13'
  version '1.6.16'

  skip_on :Mac_OS_X

  if PACKMAN::OS.distro == :Mac_OS_X
    def system_prefix
      '/usr/X11'
    end
  end

  def install
    args = %W[
      --prefix=#{prefix}
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
