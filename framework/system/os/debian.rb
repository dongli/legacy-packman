module PACKMAN
  class Debian < Os
    vendor :Debian
    type :Debian
    check :version do
      `cat /etc/*-release`.match(/VERSION_ID="(.+)"/)[1]
    end
    package_manager :DPKG, {
      :query_command => 'dpkg --status',
      :install_command => 'sudo apt-get install'
    }
  end
end
