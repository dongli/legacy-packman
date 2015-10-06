class Libpng < PACKMAN::Package
  url 'http://nchc.dl.sourceforge.net/project/libpng/libpng16/older-releases/1.6.16/libpng-1.6.16.tar.gz'
  sha1 '50f3b31d013a31e2cac70db177094f6a7618b8be'
  version '1.6.16'

  label :unlinked if PACKMAN.mac?

  depends_on :zlib

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
