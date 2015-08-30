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
    command :check_user do |name|
      res = `id -u #{name} 2>&1`
      $?.success?
    end
    command :check_group do |name|
      res = `id -g #{name} 2>&1`
      $?.success?
    end
    command :create_user do |name, *options|
      PACKMAN.report_notice "Create user #{PACKMAN.blue name}."
      if check_user name
        PACKMAN.report_error "User #{PACKMAN.red name} exists!"
      end
      args = ''
      if options.include? :with_group
        res = `sudo groupadd #{name}`
        PACKMAN.report_error "Failed to create group #{PACKMAN.red name}! See error:\n#{res}" if not $?.success?
        args << "-g#{name}"
      end
      if options.include? :with_home
        args << '-m'
      else
        args << '-M'
      end
      res = `sudo useradd #{args} #{name} 2>&1`
      PACKMAN.report_error "Failed to create user #{PACKMAN.red name}! See errors:\n#{res}" if not $?.success?
      PACKMAN.report_notice "Please enter a password for user #{PACKMAN.blue name}:"
      system "sudo passwd #{name}"
      PACKMAN.report_error "Failed to set password for #{PACKMAN.red name}!" if not $?.success?
    end
    command :delete_user do |name|
      PACKMAN.report_notice "Delete user #{PACKMAN.blue name}."
      if name == ENV['USER']
        PACKMAN.report_error "Cannot delete current user #{PACKMAN.red name}!"
      end
      if not check_user name
        PACKMAN.report_error "User #{PACKMAN.red name} does not exist!"
      end
      res = `sudo userdel #{args} #{name}`
      PACKMAN.report_error "Failed to delete user #{PACKMAN.red name}!" if not $?.success?
    end
    command :change_owner do |path, owner|
      PACKMAN.report_notice "Change owner of #{PACKMAN.blue path} to #{PACKMAN.blue owner}."
      res = `sudo chown -R #{owner} #{path} 2>&1`
      PACKMAN.report_error "Failed to change owner of #{PACKMAN.red path} to #{PACKMAN.red owner}! See errors:\n#{res}" if not $?.success?
    end
  end
end
