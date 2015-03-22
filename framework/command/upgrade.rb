module PACKMAN
  class Commands
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
        install_package package if not is_package_installed? package
      end
    end
  end
end
