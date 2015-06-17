class Openssl < PACKMAN::Package
  url 'https://www.openssl.org/source/old/1.0.2/openssl-1.0.2a.tar.gz'
  sha1 '46ecd325b8e587fa491f6bb02ad4a9fb9f382f5f'
  version '1.0.2a'

  label :not_set_ld_library_path

  depends_on 'zlib'

  def arch_args; {
      :Mac_OS_X => {
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
    if arch_args.has_key? PACKMAN.os_type
      PACKMAN.run './Configure', *(args+arch_args[PACKMAN.os_type][PACKMAN.x86_64? ? :x86_64 : :i386])
    else
      PACKMAN.run './config', *args
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
