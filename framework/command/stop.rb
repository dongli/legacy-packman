module PACKMAN
  class Commands
    def self.stop
      if CommandLine.packages.empty?
        CLI.report_error "No package name is provided!"
      end
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        if not package.respond_to? :stop
          CLI.report_error "#{CLI.red package_name} does not provide #{CLI.blue 'stop'} method!"
        end
        package.stop
        CLI.report_notice "#{CLI.blue package_name} is stopped."
      end
    end
  end
end
