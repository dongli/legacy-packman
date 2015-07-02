module PACKMAN
  class Mac < Os
    vendor :Apple
    type :Mac_OS_X
    check :version do
      `sw_vers`.match(/ProductVersion:\s*(\d+\.\d+\.\d+)/)[1]
    end
    package_manager :Homebrew, {
      :query_command => 'brew list',
      :install_command => 'brew install'
    }
    check :Xcode do
      PACKMAN.does_command_exist? 'xcode-select'
    end
    check :CommandLineTools do
      if version >= '10.9'
        `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>&1`
      elsif version >= '10.8'
        `pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI 2>&1`
      end
      $?.success?
    end
    command :check_user do |name|
      res = `id -u #{name} 2>&1`
      $?.success?
    end
    command :get_unique_id do
      existed_ids = `dscl . list /Users UniqueID`.gsub(/^[^\s]+\s+/, '').split("\n").map { |id| id.to_i }
      id = 500
      id += 1 until not existed_ids.include? id
      id
    end
    command :get_primary_group_id do
      existed_ids = `dscl . list /Users PrimaryGroupID`.gsub(/^[^\s]+\s+/, '').split("\n").map { |id| id.to_i }
      id = 500
      id += 1 until not existed_ids.include? id
      id
    end
    command :create_user do |name|
      PACKMAN.report_notice "Create user #{PACKMAN.blue name}."
      if check_user name
        PACKMAN.report_error "User #{PACKMAN.red name} exists!"
      end
      res = `sudo dscl . create /Users/#{name} 2>&1`
      PACKMAN.report_error "Failed to create #{PACKMAN.red name}! See errors:\n#{res}" if not $?.success?
      res = `sudo dscl . create /Users/#{name} UserShell /bin/bash`
      PACKMAN.report_error "Failed to set user shell for #{PACKMAN.red name}! See errors:\n#{res}" if not $?.success?
      unique_id = get_unique_id
      res = `sudo dscl . create /Users/#{name} UniqueID #{unique_id} 2>&1`
      PACKMAN.report_error "Failed to set user id for #{PACKMAN.red name}! See errors:\n#{res}" if not $?.success?
      primary_group_id = get_primary_group_id
      res = `sudo dscl . create /Users/#{name} PrimaryGroupID #{primary_group_id} 2>&1`
      PACKMAN.report_error "Failed to set group id for #{PACKMAN.red name}! See errors:\n#{res}" if not $?.success?
      PACKMAN.report_notice "Please enter a password for user #{PACKMAN.blue name}:"
      system "sudo dscl . passwd /Users/#{name}"
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
      res = `sudo dscl . delete /Users/#{name}`
      PACKMAN.report_error "Failed to delete user #{PACKMAN.red name}!" if not $?.success?
    end
    command :change_owner do |path, owner|
      PACKMAN.report_notice "Change owner of #{PACKMAN.blue path} to #{PACKMAN.blue owner}."
      res = `sudo chown -R #{owner} #{path} 2>&1`
      PACKMAN.report_error "Failed to change owner of #{PACKMAN.red path} to #{PACKMAN.red owner}! See errors:\n#{res}" if not $?.success?
    end
  end
end
