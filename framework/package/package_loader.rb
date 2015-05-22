module PACKMAN
  class PackageLoader
    # Collect package definition files.
    @@package_files = {}
    tmp = Dir.glob("#{ENV['PACKMAN_ROOT']}/packages/*.rb")
    tmp.delete("#{ENV['PACKMAN_ROOT']}/packages/packman_packages.rb")
    tmp.each do |file|
      name = File.basename(file).split('.').first.capitalize.to_sym
      @@package_files[name] = file
    end
    @@package_options = {}

    def self.package_options package_name
      if @@package_options.has_key? package_name
        @@package_options[package_name]
      else
        {}
      end
    end

    # Define a recursive function to load package definition files.
    def self.load_package package_name, options = nil
      package_name = package_name.capitalize.to_sym if package_name.class == String
      # Update package options from the external options.
      load @@package_files[package_name]
      package = Package.instance package_name
      # Check possible package options from config file.
      ConfigManager.propagate_options_to package
      # Check possible package options from command line.
      CommandLine.propagate_options_to package
      @@package_options[package_name] = package.options.clone
      @@package_options[package_name].merge! options if options
      package.dependencies.clear
      # The package dependency may be changed by options.
      load @@package_files[package_name]
      package = Package.instance package_name
      # Load dependent packages.
      package.dependencies.each do |depend_name|
        next if depend_name == :package_name # Skip the placeholder :package_name. TODO: Clean this out!
        load @@package_files[depend_name]
        if package.has_label? :master_package
          options = PackageGroupHelper.inherit_options package.options, depend_name
        else
          options = {}
        end
        load_package depend_name, options
        depend_package = Package.instance depend_name
      end
    end

    def self.init
      packages = CommandLine.packages.empty? ? ConfigManager.package_options.keys : CommandLine.packages.uniq
      packages.each do |package_name|
        load_package package_name
      end
    end
  end
end
