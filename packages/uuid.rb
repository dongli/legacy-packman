class Uuid < PACKMAN::Package
  url 'ftp://ftp.ossp.org/pkg/lib/uuid/uuid-1.6.2.tar.gz'
  sha1 '3e22126f0842073f4ea6a50b1f59dcb9d094719f'
  version '1.6.2'

  label 'should_provided_by_system'

  def install
    uuid = PACKMAN::Package.prefix(self)
    args = %W[
      --prefix=#{uuid}
      --disable-debug
      --without-perl
      --without-php
      --without-pgsql
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
    # Some packages include Uuid as:
    # #include <uuid/uuid.h>
    #           ^^^^^
    # So we need to add a link.
    PACKMAN.mkdir "#{uuid}/include/uuid"
    PACKMAN.ln "#{uuid}/include/uuid.h", "#{uuid}/include/uuid/uuid.h"
  end

  def installed?
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.installed? 'uuid-dev'
    elsif PACKMAN::OS.distro == :CentOS or PACKMAN::OS.distro == :Fedora
      return PACKMAN::OS.installed? 'uuid-devel'
    elsif PACKMAN::OS.mac_gang?
      return File.exist? '/usr/include/uuid/uuid.h'
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.how_to_install 'uuid-dev'
    elsif PACKMAN::OS.distro == :CentOS or PACKMAN::OS.distro == :Fedora
      return PACKMAN::OS.how_to_install 'uuid-devel'
    elsif PACKMAN::OS.mac_gang?
      return 'You should install Xcode and command line tools.'
    end
  end
end
