module PACKMAN
  class Commands
    def self.store
      if not Storage.is_authenticated?
        PACKMAN.report_error 'You are not authenticated to store the package online!'
      end
      CommandLine.packages.uniq.each do |package_name|
        package = Package.instance package_name
        Storage.upload package
      end
    end
  end
end
