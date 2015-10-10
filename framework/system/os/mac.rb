module PACKMAN
  class Mac < Os
    vendor :Apple
    type :Mac
    check :version do
      `sw_vers`.match(/ProductVersion:\s*(\d+\.\d+(\.\d+)?)/)[1]
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
    command :is_dynamic_library? do |path|
      `file #{path}`.match(/Mach-O.*dynamically linked shared library/) != nil
    end
    command :parse_load_commands do |file|
      load_commands = []
      cmd = nil
      `otool -l #{file}`.each_line do |line|
        if not cmd and line =~ /cmd LC_RPATH/
          cmd = :lc_rpath
          load_commands << { cmd => {} }
          next
        end
        if cmd == :lc_rpath
          path = line.match(/path ([^\s]+)/)
          if path
            load_commands.last[cmd][:path] = path[1]
            cmd = nil
            next
          end
        end
        if not cmd and line =~ /cmd LC_ID_DYLIB/
          cmd = :lc_id_dylib
          load_commands << { cmd => {} }
          next
        end
        if cmd == :lc_id_dylib
          name = line.match(/name ([^\s]+)/)
          if name
            load_commands.last[cmd][:name] = name[1]
            cmd = nil
            next
          end
        end
        if not cmd and line =~ /cmd LC_LOAD_DYLIB/
          cmd = :lc_load_dylib
          load_commands << { cmd => {} }
          next
        end
        if cmd == :lc_load_dylib
          name = line.match(/name ([^\s]+)/)
          if name
            load_commands.last[cmd][:name] = name[1]
            cmd = nil
            next
          end
        end
      end
      load_commands
    end
    command :repair_dynamic_link do |package, file|
      if `file #{file}` =~ /Mach-O/ and not `file #{file}` =~ /stub/
        PACKMAN.report_error "You do not have permission to change #{PACKMAN.red file}!" if not File.owned? file
        writable = File.writable? file
        if not writable
          old_mode = File.stat(file).mode
          File.chmod 0744, file
        end
        root = Pathname.new ConfigManager.install_root
        relative_path = Pathname.new(file).relative_path_from Pathname.new(package.prefix)
        parse_load_commands(file).each do |load_command|
          if load_command.keys.first == :lc_id_dylib
            p "install_name_tool -id '@rpath/#{relative_path}' #{file}"
            `install_name_tool -id '@rpath/#{relative_path}' #{file}`
            PACKMAN.report_error "Failed to repair id in #{PACKMAN.red file}!" if not $?.success?
          elsif load_command.keys.first == :lc_load_dylib
            path = load_command[:lc_load_dylib][:name]
            dylib = path.match(/#{ConfigManager.install_root}\/.*\.#{PACKMAN.shared_library_suffix}/)
            next if not dylib
            pn = Pathname.new dylib.to_s
            depend_package = Package.instance pn.relative_path_from(root).to_s.split('/').first
            depend_prefix = depend_package.prefix
            dir = Pathname.new depend_prefix
            p "install_name_tool -change '#{dylib}' '@rpath/#{pn.relative_path_from dir}' #{file}"
            `install_name_tool -change '#{dylib}' '@rpath/#{pn.relative_path_from dir}' #{file}`
            PACKMAN.report_error "Failed to repair dynamic link in #{PACKMAN.red file}!" if not $?.success?
            if package.has_label? :compiler_set
              p "install_name_tool -add_rpath '#{depend_prefix}' #{file}"
              `install_name_tool -add_rpath '#{depend_prefix}' #{file}`
              PACKMAN.report_error "Failed to add rpath to #{PACKMAN.red file}!" if not $?.success?
            end
          end
        end
        File.chmod old_mode, file if not writable
      end
    end
    command :add_rpath do |package, file|
      if `file #{file}` =~ /Mach-O/ and not `file #{file}` =~ /stub/
        PACKMAN.report_error "You do not have permission to change #{PACKMAN.red file}!" if not File.owned? file
        writable = File.writable? file
        if not writable
          old_mode = File.stat(file).mode
          File.chmod 0744, file
        end
        rpath = package.has_label?(:unlinked) ? package.prefix : PACKMAN.link_root
        parse_load_commands(file).each do |load_command|
          next if not load_command.keys.first == :lc_rpath
          path = load_command[:lc_rpath][:path]
          if path == '<packman_link_root>'
            p "install_name_tool -rpath '#{path}' '#{PACKMAN.link_root}' #{file}"
            `install_name_tool -rpath '#{path}' '#{PACKMAN.link_root}' #{file}`
            PACKMAN.report_error "Failed to add rpath to #{PACKMAN.red file}!" if not $?.success?
          elsif path =~ /<packman_\w+_prefix>/
            depend_package = Package.instance path.match(/<packman_(\w+)_prefix>/)[1]
            p "install_name_tool -rpath '#{path}' '#{PACKMAN.prefix depend_package, ConfigManager.defaults[:compiler_set_index]}' #{file}"
            `install_name_tool -rpath '#{path}' '#{PACKMAN.prefix depend_package, ConfigManager.defaults[:compiler_set_index]}' #{file}`
            PACKMAN.report_error "Failed to add rpath to #{PACKMAN.red file}!" if not $?.success?
          end
        end
        File.chmod old_mode, file if not writable
      end
    end
    command :delete_rpath do |package, file|
      if `file #{file}` =~ /Mach-O/ and not `file #{file}` =~ /stub/
        PACKMAN.report_error "You do not have permission to change #{PACKMAN.red file}!" if not File.owned? file
        writable = File.writable? file
        if not writable
          old_mode = File.stat(file).mode
          File.chmod 0744, file
        end
        root = Pathname.new ConfigManager.install_root
        if package.has_label? :compiler_set
          link_root = ConfigManager.install_root+'/'+CompilerManager.compiler_sets.index { |x|
            x.installed_by_packman? and x.package_name == package.name
          }.to_s
        else
          link_root = PACKMAN.link_root
        end
        parse_load_commands(file).each do |load_command|
          next if not load_command.keys.first == :lc_rpath
          path = load_command[:lc_rpath][:path]
          if path == link_root
            p "install_name_tool -rpath '#{path}' '<packman_link_root>' #{file}"
            `install_name_tool -rpath '#{path}' '<packman_link_root>' #{file}`
            PACKMAN.report_error "Failed to change rpath in #{PACKMAN.red file}!" if not $?.success?
          elsif path =~ /#{root}/
            pn = Pathname.new path
            depend_package = Package.instance pn.relative_path_from(root).to_s.split('/').first
            if depend_package.has_label? :unlinked or package.has_label? :compiler_set
              p "install_name_tool -rpath '#{path}' '<packman_#{depend_package.name}_prefix>' #{file}"
              `install_name_tool -rpath '#{path}' '<packman_#{depend_package.name}_prefix>' #{file}`
              PACKMAN.report_error "Failed to change rpath in #{PACKMAN.red file}!" if not $?.success?
            else
              p "install_name_tool -delete_rpath '#{path}' #{file}"
              `install_name_tool -delete_rpath '#{path}' #{file}`
              PACKMAN.report_error "Failed to delete rpath to #{PACKMAN.red file}!" if not $?.success?
            end
          end
        end
        File.chmod old_mode, file if not writable
      end
    end
    command :generate_rpaths do |root, *options|
      if options.include? :wrap_flag
        [ PACKMAN.compiler(:c).flag(:rpath).(root) ]
      else
        [ root ]
      end
    end
  end
end
