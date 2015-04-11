class Xz < PACKMAN::Package
  url 'https://fossies.org/linux/misc/xz-5.2.1.tar.gz'
  sha1 '6022493efb777ff4e872b63a60be1f1e146f3c0b'
  version '5.2.1'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end