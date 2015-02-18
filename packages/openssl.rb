class Openssl < PACKMAN::Package
  url 'https://www.openssl.org/source/openssl-1.0.2.tar.gz'
  sha1 '2f264f7f6bb973af444cd9fc6ee65c8588f610cc'
  version '1.0.2'

  label 'do_not_set_ld_library_path'

  depends_on 'zlib'

  def arch_args; {
      :Mac_OS_X => {
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
    PACKMAN.run './Configure', *(args+arch_args[PACKMAN::OS.distro][PACKMAN::OS.x86_64? ? :x86_64 : :i386])
    PACKMAN.replace 'Makefile', {
      /^ZLIB_INCLUDE=\s*$/ => "ZLIB_INCLUDE=-I#{Zlib.include}",
      /^LIBZLIB=\s*$/ => "LIBZLIB=-L#{Zlib.lib}"
    }
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end
