class Curl < PACKMAN::Package
  url 'http://curl.haxx.se/download/curl-7.44.0.tar.bz2'
  sha1 '2123b6f0ce7729d07f72a6746c487bdfe35c3cc1'
  version '7.44.0'

  binary do
    compiled_on :Mac, '=~ 10.11'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 '4b14dad17489424b259356fe68066d4623594600'
    version '7.44.0'
  end

  depends_on :zlib
  depends_on :libressl

  def install
    PACKMAN.prepend_env 'PKG_CONFIG_PATH', "#{Libressl.lib}/pkgconfig"
    args = %W[
      --prefix=#{prefix}
      --with-ssl=#{Libressl.prefix}
      --with-ca-bundle=#{Libressl.etc}/libressl/cert.pem
    ]
    if PACKMAN.cygwin?
      args << "--with-ssl=#{Openssl.prefix}"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
