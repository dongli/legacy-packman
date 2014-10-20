module PACKMAN
  class Commands
    def self.remove
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        if not File.directory? "#{ConfigManager.install_root}/#{package_name.to_s.downcase}"
          CLI.report_error "Package #{CLI.red package_name} is not installed!"
        end
        versions = Dir.glob("#{ConfigManager.install_root}/#{package_name.to_s.downcase}/*").sort
        if versions.size > 1 and not CommandLine.has_option? '-all'
          CLI.report_warning "Multiple versions of package #{CLI.red package_name} have been installed."
          tmp = versions.map { |v| File.basename(v) }
          tmp << 'all'
          CLI.ask 'Which version do you want to remove?', tmp
          removed_versions = CLI.get_answer tmp
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
            if not package.has_label? 'compiler_insensitive'
              sets = Dir.glob("#{versions[j]}/*").sort
              if sets.size > 1 and not CommandLine.has_option? '-all'
                CLI.report_warning "Package #{CLI.red package_name} (#{File.basename versions[j]}) "+
                  "has been compiled by multiple compiler sets."
                tmp = sets.map { |s| i = File.basename(s).to_i; "#{ConfigManager.compiler_sets[i]}" }
                tmp << 'all'
                CLI.ask 'Which set do you want to remove?', tmp
                removed_sets = CLI.get_answer tmp
              elsif sets.size == 1
                removed_sets = [0]
              elsif CommandLine.has_option? '-all'
                removed_sets = []
                for i in 0..sets.size-1
                  removed_sets << i
                end
              else
                CLI.report_error "Unexpected situation!"
              end
              for i in 0..ConfigManager.compiler_sets.size-1
                if removed_sets.include? i or removed_sets.include? ConfigManager.compiler_sets.size
                  CLI.report_notice "Remove #{CLI.red sets[i]}."
                  PACKMAN.rm sets[i]
                end
              end
            else
              CLI.report_notice "Remove #{CLI.red versions[j]}."
              PACKMAN.rm versions[j]
            end
          end
        end
      end
    end
  end
end
