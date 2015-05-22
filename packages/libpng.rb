class Libpng < PACKMAN::Package
  url 'http://downloads.sf.net/project/libpng/libpng16/1.6.16/libpng-1.6.16.tar.gz'
  sha1 '50f3b31d013a31e2cac70db177094f6a7618b8be'
  version '1.6.16'

  label :skipped if PACKMAN.mac?

  depends_on 'zlib'

  if PACKMAN.mac?
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
    PACKMAN.set_cppflags_and_ldflags [Zlib]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end

  def installed?
    File.exist? '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ImageIO.framework/Versions/A/Resources/libPng.dylib'
  end
end
