class Openssl < PACKMAN::Package
  url 'ftp://ftp.openssl.org/source/openssl-1.0.2.tar.gz'
  sha1 '2f264f7f6bb973af444cd9fc6ee65c8588f610cc'
  version '1.0.2'

  label 'do_not_set_ld_library_path'

  depends_on 'zlib'

  def arch_args; {
      :Darwin => {
        :x86_64 => %w[darwin64-x86_64-cc enable-ec_nistp_64_gcc_128],
        :i386   => %w[darwin-i386-cc]
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
    if arch_args.has_key? PACKMAN.os_type
      PACKMAN.run './Configure', *(args+arch_args[PACKMAN.os_type][PACKMAN.x86_64? ? :x86_64 : :i386])
    else
      res = `./config`
      args << res.lines.last.match(/^Configured for (.+)\./)[1]
      PACKMAN.run './Configure', *args
    end
    PACKMAN.replace 'Makefile', {
      /^ZLIB_INCLUDE=\s*$/ => "ZLIB_INCLUDE=-I#{Zlib.include}",
      /^LIBZLIB=\s*$/ => "LIBZLIB=-L#{Zlib.lib}"
    }
    if PACKMAN.compiler('c').vendor == 'pgi'
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
end
