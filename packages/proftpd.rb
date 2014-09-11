class Proftpd < PACKMAN::Package
  url 'ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.5.tar.gz'
  sha1 '9859b1e6b5e2731d7b1147f875fbdb0d4738c688'
  version '1.3.5'

  def install
    PACKMAN.replace 'sample-configurations/basic.conf', {
      /^Group\s*nogroup/ => 'Group nobody'
    }
    proftpd = PACKMAN::Package.prefix(self)
    args = %W[
      --prefix=#{proftpd}
      --sysconfdir=#{proftpd}/../config
      --localstatedir=#{proftpd}/var
    ]
    PACKMAN.run './configure', *args
    if PACKMAN::OS.mac_gang?
      PACKMAN.run "make INSTALL_USER=`whoami` INSTALL_GROUP=admin install"
    else
      PACKMAN.run "make INSTALL_USER=`whoami` INSTALL_GROUP=`whoami` install"
    end
  end
end
