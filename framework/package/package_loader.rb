module PACKMAN
  class PackageLoader
    def self.delegated_methods
      [:load_package, :package_options]
    end

    # Collect package definition files.
    @@package_files = {}
    Dir.glob("#{ENV['PACKMAN_ROOT']}/packages/*.rb").each do |file|
      name = File.basename(file).split('.').first.to_sym
      @@package_files[name] = file
    end
    @@package_options = {}

    def self.package_options package_name
      @@package_options[package_name] || {}
    end

    # Define a recursive function to load package definition files.
    def self.load_package package_name, options = nil
      package_name = package_name.to_s.downcase.to_sym
      # Update package options from the external options.
      load @@package_files[package_name]
      package = Package.instance package_name
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
        load @@package_files[depend_name.to_sym]
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
      # Load each package specified in command line.
      CommandLine.packages.uniq.each do |package_name|
        load_package package_name
      end
    end
  end
end
