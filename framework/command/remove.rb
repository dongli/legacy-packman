module PACKMAN
  class Commands
    def self.remove
      if CommandLine.packages.empty?
        CLI.report_error "No package name is provided!"
      end
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        package_root = "#{ConfigManager.install_root}/#{package.name}"
        if not File.directory? package_root
          if package.respond_to? :remove
            package.remove
          else
            CLI.report_error "Package #{CLI.red package.name} is not installed!"
          end
        end
        versions = Dir.glob("#{package_root}/*").sort
        if versions.size > 1 and not CommandLine.has_option? '-all'
          CLI.report_warning "Multiple versions of package #{CLI.red package_name} have been installed."
          tmp = versions.map { |v| File.basename(v) }
          tmp << 'all'
          CLI.ask 'Which version do you want to remove?', tmp
          removed_versions = CLI.get_answer :possible_answers => tmp
        elsif versions.size == 1
          removed_versions = [0]
        elsif CommandLine.has_option? '-all'
          removed_versions = []
          for i in 0..versions.size-1
            removed_versions << i
          end
        end
        for j in 0..versions.size-1
          if removed_versions.include? j or removed_versions.include? versions.size
            handle_removed_compiler_set package
            if not package.has_label? :compiler_insensitive
              sets = Dir.glob("#{versions[j]}/*").sort
              # Check if sets are 0, 1, ...
              sets.each do |set|
                begin
                  compiler_set_index = Integer File.basename(set)
                  raise if compiler_set_index >= CompilerManager.compiler_sets.size
                rescue
                  CLI.report_error "There are unknown files in #{package_root}!\n"+
                    "#{CLI.red '==>'} #{set}"
                end
              end
              removed_sets = []
              if sets.size > 1 and not CommandLine.has_option? '-all'
                CLI.report_warning "Package #{CLI.red package_name} (#{File.basename versions[j]}) "+
                  "has been compiled by multiple compiler sets."
                tmp = sets.map { |s|
                  i = File.basename(s).to_i
                  CompilerManager.compiler_sets[i].compilers.map { |language, compiler|
                    compiler.command
                  }
                }
                tmp << 'all'
                CLI.ask 'Which set do you want to remove?', tmp
                removed_sets = CLI.get_answer :possible_answers => tmp
                if removed_sets.include? tmp.size-1
                  removed_sets = Array.new(sets.size) { |i| i }
                end
              elsif sets.size == 1
                removed_sets << 0
              elsif CommandLine.has_option? '-all'
                removed_sets = Array.new(sets.size) { |i| i }
              end
              for i in 0..sets.size-1
                if removed_sets.include? i
                  CLI.report_notice "Remove #{CLI.red sets[i]}."
                  CompilerManager.activate_compiler_set sets[i].split('/').last
                  Commands.unlink package_name
                  PACKMAN.rm sets[i]
                end
              end
            else
              CLI.report_notice "Remove #{CLI.red versions[j]}."
              for i in 0..CompilerManager.compiler_sets.size-1
                CompilerManager.activate_compiler_set i
                Commands.unlink package_name
              end
              PACKMAN.rm versions[j]
            end
            # Remove empty directory if there is.
            PACKMAN.rm versions[j] if PACKMAN.is_directory_empty? versions[j]
          end
        end
        # Remove empty directory if there is.
        PACKMAN.rm package_root if PACKMAN.is_directory_empty? package_root
      end
    end

    def self.handle_removed_compiler_set package
      return if not package.has_label? :compiler_set
      # Get compiler set index for package.
      package_hash = Files::Info.read package
      index = CompilerManager.compiler_sets.index do |compiler_set|
        compiler_set.installed_by_packman? and
        compiler_set.package_name == package.name and
        compiler_set.compilers[:c].version == package_hash[:version]
      end
      if index < CompilerManager.compiler_sets.size-1
        PACKMAN.report_error "Package #{PACKMAN.green package.name} is not the last compiler set, and PACKMAN is not programmed to handle this case! Sorry!!"
      end
      # Check if there is any other packages compiled by this compiler set.
      installed_packages.each do |package_name, version_set_pairs|
        if version_set_pairs.values.map { |s| s.include? index }.include? true
          PACKMAN.report_error "There are packages compiled by #{PACKMAN.green package.name}!"
        end
      end
      # Unlink package.
      CompilerManager.activate_compiler_set index
      Commands.unlink package.name
      # Remove from configure file if package is a compiler set.
      CompilerManager.compiler_sets.delete_at index
      if ConfigManager.defaults[:compiler_set_index] == index
        ConfigManager.defaults[:compiler_set_index] = 0
        PACKMAN.report_warning "Default compiler set is changed to 0!"
      end
      ConfigManager.write
      CompilerManager.activate_default_compiler_set
    end
  end
end
