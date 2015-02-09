module PACKMAN
  class DebianSpec < OsSpec
    vendor :Debian
    type :Linux
    distro :Debian
    version {
      `cat /etc/*-release`.match(/VERSION_ID="(\d+)"/)[1]
    }
    package_manager :DPKG, {
      :query_command => 'dpkg-query -l',
      :install_command => :'sudo apt-get install'
    }
  end
end
