class Uuid < PACKMAN::Package
  # OSSP-UUID has problems to be used, so I use the one in e2fsprogs.
  url 'http://jaist.dl.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.42.11/e2fsprogs-1.42.11.tar.gz'
  sha1 '3d30eb40f3ca69dcef373a505a061b582e1026c2'
  version '1.42.11'

  label 'use_system_first'

  def install
    uuid = PACKMAN::Package.prefix(self)
    args = %W[
      --prefix=#{uuid}
      CFLAGS=-fPIC
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
    PACKMAN.run 'make install-libs'
  end

  def installed?
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.installed? 'uuid-dev'
    elsif PACKMAN::OS.distro == :CentOS or PACKMAN::OS.distro == :Fedora
      return PACKMAN::OS.installed? 'uuid-devel'
    elsif PACKMAN::OS.distro == :RedHat_Enterprise
      # It seems that RedHat Enterprise does not provide uuid package but ship
      # it builtin.
      return File.exist? '/usr/include/uuid/uuid.h'
    elsif PACKMAN::OS.mac_gang?
      return File.exist? '/usr/include/uuid/uuid.h'
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.how_to_install 'uuid-dev'
    elsif PACKMAN::OS.distro == :CentOS or PACKMAN::OS.distro == :Fedora
      return PACKMAN::OS.how_to_install 'uuid-devel'
    elsif PACKMAN::OS.distro == :RedHat_Enterprise
      return 'RedHat Enterprise should provide UUID already!'
    elsif PACKMAN::OS.mac_gang?
      return 'You should install Xcode and command line tools.'
    end
  end
end
