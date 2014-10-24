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

    # Define a recursive function to load package definition files.
    def self.load_package package_name, options = {}
      # Update package options from the external options.
      load @@package_files[package_name]
      package = Package.instance package_name
      if options
        options.each do |key, value|
          if package.options.has_key? key
            package.update_option key, value, true
          end
        end
      end
      # The package dependency may be changed by options.
      load @@package_files[package_name]
      package = Package.instance package_name, options # NOTE: We need 'options' argument!
      # Load dependent packages.
      package.dependencies.each do |depend_name|
        next if depend_name == :package_name # Skip the placeholder :package_name.
        load @@package_files[depend_name]
        depend_package = Package.instance depend_name
        package.options.each do |key, value|
          depend_package.update_option key, value, true
        end
        load_package depend_name, options if not depend_package.options.empty?
      end
    end

    def self.init
      ConfigManager.package_options.each do |package_name, options|
        load_package package_name, options
      end
    end
  end
end
