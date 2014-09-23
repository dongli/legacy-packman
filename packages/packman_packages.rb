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
    def self.load_package package_name, install_spec
      load @@package_files[package_name]
      if install_spec
        package = PACKMAN::Package.instance package_name, install_spec
        install_spec.each do |key, value|
          if package.options.has_key? key
            case package.options[key]
            when :package_name
              if (not value.class == String and not value.class == Symbol) or not PACKMAN::Package.defined? value
                PACKMAN::CLI.report_error "Option #{CLI.red key} for #{CLI.red package_name} should be set to a valid package name!"
              end
            when :boolean
              if not !!value == value
                PACKMAN::CLI.report_error "Option #{CLI.red key} for #{CLI.red package_name} should be set to a boolean!"
              end
            end
            package.options[key] = value
          end
        end
      else
        package = PACKMAN::Package.instance package_name
      end
      package.dependencies.each do |depend|
        depend_name = depend.capitalize.to_sym
        load @@package_files[depend_name]
        depend_package = PACKMAN::Package.instance depend_name
        package.options.each do |key, value|
          if depend_package.options.has_key? key
            depend_package.options[key] = value
          end
        end
        load_package depend_name, nil if not depend_package.options.empty?
      end
    end

    def self.init
      PACKMAN::ConfigManager.packages.each do |package_name, install_spec|
        load_package package_name, install_spec
      end
    end
  end
end

PACKMAN::PackageLoader.init

