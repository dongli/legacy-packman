module PACKMAN
  class DebianSpec < OsSpec
    vendor :Debian
    type :Linux
    distro :Debian
    check :version do
      `cat /etc/*-release`.match(/VERSION_ID="(\d+)"/)[1]
    end
    package_manager :DPKG, {
      :query_command => 'dpkg --status',
      :install_command => 'sudo apt-get install'
    }
  end
end
