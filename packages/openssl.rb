class Openssl < PACKMAN::Package
  url 'https://www.openssl.org/source/old/1.0.2/openssl-1.0.2a.tar.gz'
  sha1 '46ecd325b8e587fa491f6bb02ad4a9fb9f382f5f'
  version '1.0.2a'

  label :unlinked

  depends_on :zlib

  def arch_args; {
      :Mac => {
        :x86_64 => %w[darwin64-x86_64-cc enable-ec_nistp_64_gcc_128],
        :i386   => %w[darwin-i386-cc]
      },
      :Cygwin => {
        :x86_64 => %w[Cygwin-x86_64],
        :i386   => %w[Cygwin]
      }
  }; end

  def install
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{etc}/openssl
      zlib-dynamic
      shared
      enable-cms
    ]
    if arch_args.has_key? PACKMAN.os.type
      PACKMAN.run './Configure', *(args+arch_args[PACKMAN.os.type][PACKMAN.os.x86_64? ? :x86_64 : :i386])
    else
      PACKMAN.run './config', *args
    end
    if PACKMAN.compiler(:c).vendor == :pgi
      PACKMAN.replace 'Makefile', {
        '-fomit-frame-pointer' => '',
        '-Wall' => '',
        '-fno-common' => '',
        '-arch x86_64' => ''
      }, :not_exit
      ['crypto/md32_common.h', 'crypto/md4/md4_dgst.c', 'crypto/sha/sha_locl.h', 'crypto/sha/sha512.c',
       'crypto/ripemd/rmd_dgst.c', 'crypto/des/ecb_enc.c', 'crypto/des/cfb64enc.c', 'crypto/des/cfb64ede.c',
       'crypto/des/cfb_enc.c', 'crypto/des/ofb64enc.c', 'crypto/des/ofb_enc.c', 'crypto/des/qud_cksm.c',
       'crypto/des/des_enc.c', 'crypto/des/fcrypt_b.c', 'crypto/des/xcbc_enc.c']
    end
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end

  def post_install
    cert_pem = File.new etc+'/openssl/cert.pem', 'w'
    if PACKMAN.mac?
      keychains = %w[
        /Library/Keychains/System.keychain
        /System/Library/Keychains/SystemRootCertificates.keychain
      ]
      keychains.each do |keychain|
        cert_pem << `security find-certificate -a -p #{keychain}`
      end
    end
  end
end
