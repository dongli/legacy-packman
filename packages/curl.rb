class Curl < PACKMAN::Package
  url 'http://curl.haxx.se/download/curl-7.44.0.tar.bz2'
  sha1 '879a186944e7b06e619a2eb07cef729b5702345c'
  version '7.44.0'

  depends_on :zlib
  depends_on :libressl

  def install

    if PACKMAN.os.type == :Fedora
      PACKMAN.replace 'lib/vtls/openssl.c', {
        '#if defined(HAVE_RAND_EGD)' => "#undef HAVE_RAND_EGD\n#if defined(HAVE_RAND_EGD)"
      }
    end

    PACKMAN.prepend_env 'PKG_CONFIG_PATH', "#{Libressl.lib}/pkgconfig"
    PACKMAN.handle_unlinked Libressl
    args = %W[
      --prefix=#{prefix}
      --with-ssl=#{Libressl.prefix}
      --with-ca-bundle=#{Libressl.etc}/libressl/cert.pem
      --with-ca-path=#{Libressl.etc}/libressl
    ]
    if PACKMAN.cygwin?
      args << "--with-ssl=#{Openssl.prefix}"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
