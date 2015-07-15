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
    command :check_group do |name|
      res = `dscl . list /Groups | grep #{name} 2>&1`
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
    command :is_user_in_group? do |user_name, group_name|
      (`id #{user_name}`.split.select{ |x| x =~ /groups/ }).first.match(group_name) != nil
    end
    command :add_user_to_group do |user_name, group_name|
      if not is_user_in_group? user_name, group_name
        res = `sudo dseditgroup -o edit -a #{user_name} -t user #{group_name}`
        PACKMAN.report_error "Failed to add user #{PACKMAN.red user_name} to group #{PACKMAN.red group_name}! See errors:\n#{res}" if not $?.success?
      end
    end
    command :create_user do |name, options = []|
      options = [options] if not options.class == Array
      PACKMAN.report_notice "Create user #{PACKMAN.blue name}."
      if check_user name
        PACKMAN.report_error "User #{PACKMAN.red name} exists!"
      end
      res = `sudo dscl . create /Users/#{name} 2>&1`
      PACKMAN.report_error "Failed to create user #{PACKMAN.red name}! See errors:\n#{res}" if not $?.success?
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
      if options.include? :with_group
        res = `sudo dscl . create /Groups/#{name}`
        PACKMAN.report_error "Failed to create group #{PACKMAN.red name}! See error:\n#{res}" if not $?.success?
        res = `sudo dscl . create /Groups/#{name} passwd "*"`
        PACKMAN.report_error "Failed to passwd group #{PACKMAN.red name}! See error:\n#{res}" if not $?.success?
        res = `sudo dscl . create /Groups/#{name} gid #{primary_group_id}`
        PACKMAN.report_error "Failed to set group id for #{PACKMAN.red name}! See error:\n#{res}" if not $?.success?
      end
      if options.include? :with_home
        res = `sudo dscl . create /Users/#{name} NFSHomeDirectory /Users/#{name}`
        PACKMAN.report_error "Failed to create home for #{PACKMAN.red name}!" if not $?.success?
        if not File.directory? "/Users/#{name}"
          res = `sudo mkdir /Users/#{name}`
          PACKMAN.report_error "Failed to create home for #{PACKMAN.red name}!" if not $?.success?
        end
        if options.include? :with_group
          change_owner "/Users/#{name}", name+':'+name
        else
          change_owner "/Users/#{name}", name
        end
      end
      if options.include? :hide_login
        res = `sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add #{name}`
        PACKMAN.report_error "Failed to hide #{PACKMAN.red name} from login screen!" if not $?.success?
      end
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
    command :cron_job_exist? do |label|
      not `launchctl list | grep '#{label}'`.empty?
    end
    command :start_cron_job do |options|
      PACKMAN.report_error "Options does not contain #{PACKMAN.red label}!" if not options.has_key? :label
      PACKMAN.report_notice "Start a cron job #{PACKMAN.blue options[:label]}."
      plist_file = "#{ENV['HOME']}/Library/LaunchAgents/#{options[:label]}.plist"
      file = File.new(plist_file, 'w')
      file << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
      file << "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
      file << "<plist version=\"1.0\">\n"
      file << "<dict>\n"
      file << "  <key>Label</key>\n"
      file << "  <string>#{options[:label]}</string>\n"
      file << "  <key>ProgramArguments</key>\n"
      file << "  <array>\n"
      file << "    <string>#{options[:command]}</string>\n"
      if options.has_key? :arguments
        if options[:arguments].class == Array
          args = options[:arguments]
        elsif options[:arguments].class == String
          args = options[:arguments].split
        end
        args.each do |arg|
          file << "    <string>#{arg}</string>\n"
        end
      end
      file << "  </array>\n"
      if options.has_key? :run_at_load
        file << "  <key>RunAtLoad</key>\n"
        file << "  <#{options[:run_at_load]}/>\n"
      end
      if options.has_key? :keep_alive
        file << "  <key>KeepAlive</key>\n"
        file << "  <#{options[:keep_alive]}/>\n"
      end
      if options.has_key? :group_name
        file << "  <key>GroupName</key>\n"
        file << "  <string>#{options[:group_name]}</string>\n"
      end
      if options.has_key? :user_name
        file << "  <key>UserName</key>\n"
        file << "  <string>#{options[:user_name]}</string>\n"
      end
      if options.has_key? :every
        if options[:every].has_key? :second
          file << "  <key>StartInterval</key>\n"
          file << "  <integer>#{options[:every][:second]}</integer>\n"
        end
        if options[:every].keys & [:minute, :hour, :day, :weekday, :month] != []
          file << "  <key>StartCalendarInterval</key>\n"
          file << "  <dict>\n"
          if options[:every].has_key? :minute
            file << "    <key>Minute</key>\n"
            file << "    <integer>#{options[:every][:minute]}</integer>\n"
          end
          if options[:every].has_key? :hour
            file << "    <key>Hour</key>\n"
            file << "    <integer>#{options[:every][:hour]}</integer>\n"
          end
          if options[:every].has_key? :day
            file << "    <key>Day</key>\n"
            file << "    <integer>#{options[:every][:day]}</integer>\n"
          end
          if options[:every].has_key? :weekday
            file << "    <key>Day</key>\n"
            file << "    <integer>#{options[:every][:weekday]}</integer>\n"
          end
          if options[:every].has_key? :month
            file << "    <key>Day</key>\n"
            file << "    <integer>#{options[:every][:month]}</integer>\n"
          end
          file << "  </dict>\n"
        end
      end
      if options.has_key? :working_directory
        file << "  <key>WorkingDirectory</key>\n"
        file << "  <string>#{options[:working_directory]}</string>\n"
      end
      if options.has_key? :stdout
        file << "  <key>StandardOutPath</key>\n"
        file << "  <string>#{options[:stdout]}</string>\n"
      end
      if options.has_key? :stderr
        file << "  <key>StandardErrorPath</key>\n"
        file << "  <string>#{options[:stderr]}</string>\n"
      end
      file << "</dict>\n"
      file << "</plist>\n"
      file.close
      if cron_job_exist? options[:label]
        res = `launchctl unload #{plist_file}`
        PACKMAN.report_error "Failed to unload #{PACKMAN.red plist_file}!" if not $?.success?
      end
      res = `launchctl load #{plist_file}`
      PACKMAN.report_error "Failed to load #{PACKMAN.red plist_file}!" if not $?.success?
      res = `launchctl start #{options[:label]}`
      PACKMAN.report_error "Failed to start a cron job #{PACKMAN.red options[:label]}!" if not $?.success?
    end
    command :stop_cron_job do |options|
      if not options.has_key? :label
        PACKMAN.report_error "Options do not contain cron job #{PACKMAN.red 'label'}!"
      end
      PACKMAN.report_notice "Stop a cron job #{PACKMAN.blue options[:label]}."
      res = `launchctl stop #{options[:label]}`
      PACKMAN.report_error "Failed to stop a cron job #{PACKMAN.red options[:label]}!" if not $?.success?
      plist_file = "#{ENV['HOME']}/Library/LaunchAgents/#{options[:label]}.plist"
      res = `launchctl unload #{plist_file}`
      PACKMAN.report_error "Failed to unload a cron job #{PACKMAN.red options[:label]}!" if not $?.success?
    end
    command :status_cron_job do |options|
      if not options.has_key? :label
        PACKMAN.report_error "Options do not contain cron job #{PACKMAN.red 'label'}!"
      end
      res = `launchctl list #{options[:label]} 2>&1`
      $?.success?
    end
  end
end
