module PACKMAN
  class Suse < Os
    vendor :Novell
    type :SUSE
    check :version do
      tmp = `cat /etc/*-release`.match(/VERSION = (\d+)\nPATCHLEVEL = (\d)/m)
      "#{tmp[1]}.#{tmp[2]}"
    end
    package_manager :YaST, {
      :query_command => 'rpm -qi',
      :install_command => 'sudo zypper install',
      :version_pattern => /Version\s*:\s*(.*)\s*Vendor/
    }
  end
end
