module PACKMAN
  class Commands
    def self.stop
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        set = ConfigManager.packages[package_name]['compiler_set']
        Package.compiler_set = ConfigManager.compiler_sets[set.first]
        if not package.respond_to? :stop
          CLI.report_error "#{CLI.red package_name} does not provide #{CLI.blue 'stop'} method!"
        end
        package.stop
        PACKMAN::CLI.report_notice "#{CLI.green package_name} is stopped."
      end
    end
  end
end
