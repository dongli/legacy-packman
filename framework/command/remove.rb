module PACKMAN
  class Commands
    def self.remove
      if CommandLine.packages.empty?
        CLI.report_error "No package name is provided!"
      end
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        package_root = "#{ConfigManager.install_root}/#{package_name.to_s.downcase}"
        if not File.directory? package_root
          if package.respond_to? :remove
            package.remove
          else
            CLI.report_error "Package #{CLI.red package_name} is not installed!"
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
            if not package.has_label? :compiler_insensitive and not package.has_label? :binary
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
                  PACKMAN.delete_from_file "#{ConfigManager.install_root}/packman.bashrc",
                    "source #{sets[i]}/bashrc", :no_error
                  PACKMAN.rm sets[i]
                  ConfigManager.package_options[package_name]['compiler_set_indices'].delete i if ConfigManager.package_options.has_key? package_name
                end
              end
              # When all compiler sets compiled versions are removed, remove the package item from config file.
              if ConfigManager.package_options.has_key?(package_name) and
                 ConfigManager.package_options[package_name]['compiler_set_indices'].empty?
                ConfigManager.package_options.delete package_name
              end
            else
              CLI.report_notice "Remove #{CLI.red versions[j]}."
              PACKMAN.delete_from_file "#{ConfigManager.install_root}/packman.bashrc",
                "source #{versions[j]}/bashrc", :no_error
              PACKMAN.rm versions[j]
              ConfigManager.package_options.delete package_name # Remove the package item from config file.
            end
            # Remove empty directory if there is.
            PACKMAN.rm versions[j] if PACKMAN.is_directory_empty? versions[j]
          end
        end
        # Remove empty directory if there is.
        PACKMAN.rm package_root if PACKMAN.is_directory_empty? package_root
      end
      # Update config file.
      ConfigManager.write
    end
  end
end
