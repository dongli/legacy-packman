class Libevent < PACKMAN::Package
  url 'https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz'
  sha1 '3e6674772eb77de24908c6267c698146420ab699'
  version '2.0.21'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-debug-mode
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
