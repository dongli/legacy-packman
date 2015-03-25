module PACKMAN
  class Commands
    def self.is_any_package_installed
      @@is_any_package_upgraded ||= false
    end

    def self.upgrade
      packages = CommandLine.packages.empty? ? ConfigManager.package_options.keys : CommandLine.packages.uniq
      packages.each do |package_name|
        package = Package.instance package_name
        if package.has_label? 'install_with_source' and
           not CommandLine.packages.include? package_name
          # 'install_with_source' packages should only be specified in command line.
          next
        end
        # Binary is preferred.
        if ( package.has_binary? and not package.use_binary? and not CommandLine.has_option? '-use_binary') or package.use_binary?
          package = Package.instance package_name, 'use_binary' => true
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
