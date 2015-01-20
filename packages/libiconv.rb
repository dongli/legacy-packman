class Libiconv < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/libiconv/libiconv-1.14.tar.gz'
  sha1 'be7d67e50d72ff067b2c0291311bc283add36965'
  version '1.14'

  skip_on :Mac_OS_X

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-debug
      --disable-dependency-tracking
      --enable-extra-encodings
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
