class Curl < PACKMAN::Package
  url 'http://curl.haxx.se/download/curl-7.37.1.tar.gz'
  sha1 '2123b6f0ce7729d07f72a6746c487bdfe35c3cc1'
  version '7.37.1'

  depends_on 'openssl'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
