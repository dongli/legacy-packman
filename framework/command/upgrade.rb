module PACKMAN
  class Commands
    def self.is_any_package_upgraded
      @@is_any_package_upgraded ||= false
    end

    def self.upgrade
      packages = CommandLine.packages.empty? ? ConfigManager.package_options.keys : CommandLine.packages.uniq
      packages.each do |package_name|
        package = Package.instance package_name
        if package.has_label? :installed_with_source and
           not CommandLine.packages.include? package_name
          # :installed_with_source packages should only be specified in command line.
          next
        end
        # Binary is preferred.
        if ( package.has_binary? and not package.use_binary? and not CommandLine.has_option? '-use_binary') or package.use_binary?
          package = Package.instance package_name, :use_binary => true
        end
        if package.compiler_set_indices.empty? and not package.use_binary?
          if ConfigManager.defaults.has_key? 'compiler_set_index'
            # Use the default compiler set if specified.
            package.compiler_set_indices << ConfigManager.defaults[:compiler_set_index]
          else
            # Ask user to choose the compiler sets.
            tmp = CompilerManager.compiler_sets.clone
            tmp << 'all'
            CLI.ask 'Which compiler sets do you want to use?', tmp
            ans = CLI.get_answer :possible_answers => tmp
            for i in 0..CompilerManager.compiler_sets.size-1
              if ans.include? i or ans.include? CompilerManager.compiler_sets.size
                package.compiler_set_indices << i
              end
            end
          end
        end
        if not is_package_installed? package
          install_package package
          @@is_any_package_upgraded = true
        end
      end
      # Invoke switch subcommand.
      Commands.switch if is_any_package_upgraded
    end
  end
end
