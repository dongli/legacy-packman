module PACKMAN
  class Commands
    def self.switch
      if CommandLine.has_option? '-compiler_set_index'
        compiler_set_index = Integer(CommandLine.options['-compiler_set_index'])
      else
        compiler_set_index = Integer(ConfigManager.defaults['compiler_set_index'])
      end
      compiler_set = ConfigManager.compiler_sets[compiler_set_index]
      File.open("#{ConfigManager.install_root}/packman.bashrc", 'w') do |file|
        # Check if the active compiler is installed by PACKMAN.
        if compiler_set.has_key?('installed_by_packman')
          file << "source #{PACKMAN.prefix(compiler_set['installed_by_packman'])}/bashrc\n"
        end
        Dir.foreach(ConfigManager.install_root) do |dir|
          next if dir =~ /^\.{1,2}$/
          dir = "#{ConfigManager.install_root}/#{dir}"
          next if not File.directory? dir
          bashrc_files = []
          Dir.foreach(dir) do |subdir|
            next if subdir =~ /^\.{1,2}$/
            subdir = "#{dir}/#{subdir}"
            next if not File.directory? subdir
            if File.exist? "#{subdir}/bashrc"
              # The package is compiler insensitive.
              bashrc_files << "#{subdir}/bashrc"
            elsif File.exist? "#{subdir}/#{compiler_set_index}/bashrc"
              package_name = File.basename(dir)
              package = Package.instance package_name.capitalize
              if not package.conflict_packages.empty?
                # Package conflicts with other packages, so we need to check what the default package is.
                conflict_reason = package.conflict_reasons.uniq
                if not conflict_reason.size == 1
                  # Currently, we only support one conflict reason.
                  CLI.report_error "multiple conflict reasons (#{CLI.red conflict_reasons}!"
                end
                conflict_reason = conflict_reason.first
                if ConfigManager.defaults.has_key? conflict_reason
                  next if not ConfigManager.defaults[conflict_reason] == package_name
                end
              end
              # The package is built by the active compiler set.
              bashrc_files << "#{subdir}/#{compiler_set_index}/bashrc"
            end
          end
          bashrc_files.sort!
          if bashrc_files.size == 1
            file << "source #{bashrc_files.first}\n"
          elsif bashrc_files.size > 1
            available_versions = bashrc_files.map { |p| File.basename(PACKMAN.strip_dir(p, 2)) }
            package_name = File.basename(dir).capitalize.to_sym
            if not ConfigManager.package_options.has_key? package_name or
              not ConfigManager.package_options[package_name].has_key? 'version'
              msg = "Package #{CLI.red package_name} has multiple versions:\n"
              available_versions.each do |v|
                msg << "#{CLI.yellow '==>'} #{v}\n"
              end
              msg << "PACKMAN will use #{CLI.green PACKMAN.strip_dir bashrc_files.last, 2}!\n"
              msg << "If this is not what you want, you can specify the version in #{CLI.red CommandLine.config_file}."
              CLI.report_warning msg
              file << "source #{bashrc_files.last}\n"
              next
            end
            bashrc_files.each do |f|
              if f =~ /#{ConfigManager.package_options[package_name]['version']}/
                file << "source #{f}\n"
                break
              end
            end
          end
        end
      end
      if not File.open("#{ENV['HOME']}/.bashrc", 'r').read.match /source.*packman\.bashrc/
        CLI.report_notice "Add #{CLI.red "source #{ConfigManager.install_root}/packman.bashrc"} to "+
          "#{CLI.blue '~/.bashrc'} if it is not there."
      end
      CLI.report_notice "You may need to login again to make the changes effective."
    end
  end
end
