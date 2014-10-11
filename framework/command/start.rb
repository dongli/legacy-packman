module PACKMAN
  class Commands
    def self.start
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        if not package.respond_to? :start
          CLI.report_error "#{CLI.red package_name} does not provide #{CLI.blue 'start'} method!"
        end
        package.start
        PACKMAN::CLI.report_notice "#{CLI.green package_name} is started."
      end
    end
  end
end