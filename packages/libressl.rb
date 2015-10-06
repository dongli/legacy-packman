class Libressl < PACKMAN::Package
  url 'http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.2.3.tar.gz'
  sha1 '636b86365badf12364af39b4b6ee66b4633f0605'
  version '2.2.3'

  label :unlinked

  binary do
    compiled_on :Mac, '=~ 10.11'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 'd335e34ae482f145cc33bffdcc8aa55198deeae3'
    version '2.2.3'
  end

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
