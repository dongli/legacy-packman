module PACKMAN
  class Commands
    def self.status
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        set = ConfigManager.packages[package_name]['compiler_set']
        Package.compiler_set = ConfigManager.compiler_sets[set.first]
        if not package.respond_to? :status
          CLI.report_error "#{CLI.red package_name} does not provide #{CLI.blue 'status'} method!"
        end
        status = package.status
        case status
        when :on
          PACKMAN::CLI.report_notice "#{CLI.blue package_name} is #{CLI.green 'on'}."
        when :off
          PACKMAN::CLI.report_notice "#{CLI.blue package_name} is #{CLI.red 'off'}."
        else
          PACKMAN::CLI.report_notice "#{CLI.blue package_name} is #{CLI.red status}."
        end
      end
    end
  end
end
