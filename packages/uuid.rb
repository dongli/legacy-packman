class Uuid < PACKMAN::Package
  url 'http://ftp.de.debian.org/debian/pool/main/o/ossp-uuid/ossp-uuid_1.6.2.orig.tar.gz'
  sha1 '3e22126f0842073f4ea6a50b1f59dcb9d094719f'
  version '1.6.2'

  def install
    uuid = PACKMAN.prefix(self)
    args = %W[
      --prefix=#{uuid}
      --without-perl
      --without-php
      --without-pgsql
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
