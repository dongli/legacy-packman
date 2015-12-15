class Libressl < PACKMAN::Package
  url 'http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.3.0.tar.gz'
  sha1 '8fdaf420d680a536ab904ae275e7146f65afa2ba'
  version '2.3.0'

  label :unlinked

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-openssldir=#{etc}/libressl
      --sysconfdir=#{etc}/libressl
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end

  def post_install
    if PACKMAN.mac?
      keychains = %w[
        /Library/Keychains/System.keychain
        /System/Library/Keychains/SystemRootCertificates.keychain
      ]

      certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
      certs = certs_list.scan(
        /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m
      )

      valid_certs = certs.select do |cert|
        IO.popen("openssl x509 -inform pem -checkend 0 -noout", "w") do |openssl_io|
          openssl_io.write(cert)
          openssl_io.close_write
        end

        $?.success?
      end

      # LibreSSL install a default pem - We prefer to use OS X for consistency.
      PACKMAN.rm "#{etc}/libressl/cert.pem"
      PACKMAN.write_file "#{etc}/libressl/cert.pem", valid_certs.join("\n")
    end
  end
end
