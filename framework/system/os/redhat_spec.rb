module PACKMAN
  class RedHatSpec < OsSpec
    vendor :RedHat
    type :Linux
    version {
      `cat /etc/*-release`.match(/release (\d+\.\d+)/)[1]
    }
    package_manager :RPM, {
      :query_command => 'rpm -qi',
      :install_command => 'sudo yum install',
      :version_pattern => /Version\s*:\s*(.*)\s*Vendor/
    }
  end
end
