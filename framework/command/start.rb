module PACKMAN
  class Commands
    def self.start
      if CommandLine.packages.empty?
        CLI.report_error "No package name is provided!"
      end
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        set = ConfigManager.package_options[package_name]['compiler_set_indices']
        CompilerManager.activate_compiler_set set.first
        if not package.respond_to? :start
          CLI.report_error "#{CLI.red package_name} does not provide #{CLI.blue 'start'} method!"
        end
        package.start
        CLI.report_notice "#{CLI.green package_name} is started."
      end
    end
  end
end
