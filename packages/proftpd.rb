class Proftpd < PACKMAN::Package
  # NOTE: Proftpd 1.3.5 has bugs in Mac, so I choose to use 1.3.4d.
  url 'ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.4d.tar.gz'
  sha1 'a5b6c80a8ddeeeccc1c6448d797ccd62a3f63b65'
  version '1.3.4d'

  label :compiler_insensitive

  def install
    if PACKMAN.redhat?
      PACKMAN.replace 'sample-configurations/basic.conf', {
        /^Group\s*nogroup/ => 'Group nobody'
      }
    end
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{prefix}/../config
      --localstatedir=#{var}
    ]
    PACKMAN.run './configure', *args
    if PACKMAN.mac?
      PACKMAN.run "make INSTALL_USER=`whoami` INSTALL_GROUP=admin install"
    elsif PACKMAN.cygwin?
      PACKMAN.run 'make install'
    else
      PACKMAN.run "make INSTALL_USER=`whoami` INSTALL_GROUP=`whoami` install"
    end
  end

  def postfix
    PACKMAN.replace "#{prefix}/../config/proftpd.conf", {
      /^(ServerType\s*.*)$/ => "\\1\nServerLog #{prefix}/var/proftpd.log",
      /^(DefaultServer.*$)/ => "\\1\nRequireValidShell no\nWtmpLog off",  
    }
    if PACKMAN.debian?
      PACKMAN.replace "#{prefix}/../config/proftpd.conf", {
        /(<Anonymous\s+.*>)\n\s*User.*$\n\s*Group.*$/ => "\\1\nUser nobody\nGroup nogroup\n",
        /(UserAlias\s*anonymous\s*)ftp/ => '\1nobody'
      }
    end
    if PACKMAN.cygwin?
      PACKMAN.replace "#{prefix}/../config/proftpd.conf", {
        /^User\s*\w+$/ => "User SYSTEM",
        /^Group\s*\w+$/ => "Group Administrators"
      }
      File.open("#{prefix}/../register_proftpd_service_on_cygwin.sh", 'w') do |file|
        file << <<-EOT
#!/bin/sh
# File: proftpd-config.sh
# Purpose: Installs proftpd daemon as a Windows service

cygrunsrv --install proftpd \
          --path #{sbin}/proftpd.exe \
          --args "--nodaemon" \
          --type manual \
          --disp "Cygwin proftpd" \
          --desc "ProFTPD FTP daemon"
        EOT
      end
    end
  end
end
