module PACKMAN
  class SuseSpec < OsSpec
    vendor :Novell
    type :Linux
    distro :SUSE
    version {
      tmp = `cat /etc/*-release`.match(/VERSION = (\d+)\nPATCHLEVEL = (\d)/m)
      "#{tmp[1]}.#{tmp[2]}"
    }
    package_manager :YaST, {
      :query_command => 'rpm -qi',
      :install_command => 'sudo zypper install',
      :version_pattern => /Version\s*:\s*(.*)\s*Vendor/
    }
  end
end
