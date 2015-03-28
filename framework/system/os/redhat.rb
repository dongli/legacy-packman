module PACKMAN
  class RedHat < Os
    vendor :RedHat
    type :Linux
    check :version do
      `cat /etc/*-release`.match(/release (\d+\.\d+)/)[1]
    end
    package_manager :RPM, {
      :query_command => 'rpm -qi',
      :install_command => 'sudo yum install',
      :version_pattern => /Version\s*:\s*(.*)\s*Vendor/
    }
  end
end
