class Openssl < PACKMAN::Package
  url 'https://www.openssl.org/source/openssl-1.0.1i.tar.gz'
  sha1 '74eed314fa2c93006df8d26cd9fc630a101abd76'
  version '1.0.1i'

  depends_on 'zlib'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      zlib-dynamic
      shared
      enable-cms
    ]
    PACKMAN.run './config', *args
    PACKMAN.replace 'Makefile', {
      /^ZLIB_INCLUDE=\s*$/ => "ZLIB_INCLUDE=-I#{PACKMAN::Package.prefix(Zlib)}/include",
      /^LIBZLIB=\s*$/ => "LIBZLIB=-L#{PACKMAN::Package.prefix(Zlib)}/lib"
    }
    PACKMAN.run 'make'
    PACKMAN.run 'make test'
    PACKMAN.run 'make install'
  end
end
