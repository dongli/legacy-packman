class Proftpd < PACKMAN::Package
  url 'https://github.com/proftpd/proftpd/archive/v1.3.5a.tar.gz'
  sha1 '7c4027c207bdfe7c88b859810c7fa9b978b0524d'
  version '1.3.5a'
  filename 'proftpd-1.3.5a.tar.gz'

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

  def post_install
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
