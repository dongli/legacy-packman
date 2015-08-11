module PACKMAN
  class Commands
    def self.delegate
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        package.send CommandLine.package_method
      end
    end
  end
end
