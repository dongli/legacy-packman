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
    command :is_dynamic_library? do |file|
      `file #{Shellwords.escape file}`.match(/ELF.*LSB.*shared object/) != nil
    end
    command :parse_elf do |file|
      elf = {}
      `readelf -d #{Shellwords.escape file}`.each_line do |line|
        if line =~ /RPATH/
          elf[:rpath] = line.match(/\[(.*)\]/)[1].split(':')
        end
      end
      elf
    end
    command :repair_dynamic_link do |package, file|
    end
    command :add_rpath do |package, file|
      if `file #{Shellwords.escape file}` =~ /ELF.*dynamically linked/ and PACKMAN.does_command_exist? 'patchelf'
        PACKMAN.report_error "You do not have permission to change #{PACKMAN.red file}!" if not File.owned? file
        writable = File.writable? file
        if not writable
          old_mode = File.stat(file).mode
          File.chmod 0744, file
        end
        rpaths = generate_rpaths(package.has_label?(:unlinked) ? package.prefix : PACKMAN.link_root)
        # Record dependent package rpaths.
        if package.has_label? :compiler_set
          package.dependencies.each do |depend|
            depend_package = Package.instance depend
            rpaths << generate_rpaths(depend_package.prefix)
          end
        end
        rpaths.flatten!
        elf = parse_elf file
        (elf[:rpath] || []).each do |rpath|
          rpaths << rpath if not rpaths.include? rpath
        end
        p "patchelf --set-rpath '#{rpaths.join(':')}' #{file}"
        `patchelf --set-rpath '#{rpaths.join(':')}' #{file}`
        p "patchelf --shrink-rpath #{file}"
        `patchelf --shrink-rpath #{file}`
        File.chmod old_mode, file if not writable
      end
    end
    command :delete_rpath do |package, file|
      if `file #{Shellwords.escape file}` =~ /ELF.*dynamically linked/ and PACKMAN.does_command_exist? 'patchelf'
        PACKMAN.report_error "You do not have permission to change #{PACKMAN.red file}!" if not File.owned? file
        rpaths = generate_rpaths(package.has_label?(:unlinked) ? package.prefix : PACKMAN.link_root)
        writable = File.writable? file
        if not writable
          old_mode = File.stat(file).mode
          File.chmod 0744, file
        end
        elf = parse_elf file
        if elf.has_key? :rpath
          p "patchelf --set-rpath '#{elf[:rpath].reject { |x| x == rpath}.join(':')}' #{file}"
          `patchelf --set-rpath '#{elf[:rpath].reject { |x| x == rpath}.join(':')}' #{file}`
          p "patchelf --shrink-rpath #{file}"
          `patchelf --shrink-rpath #{file}`
        end
        File.chmod old_mode, file if not writable
      end
    end
    command :generate_rpaths do |root, *options|
      rpaths = []
      Dir.glob("#{root}/*").each do |dir|
        next if not File.directory? dir or not File.basename(dir) =~ /lib/
        if options.include? :wrap_flag
          rpaths << PACKMAN.compiler(:c).flag(:rpath).(dir)
        else
          rpaths << dir
        end
      end
      rpaths
    end
  end
end
