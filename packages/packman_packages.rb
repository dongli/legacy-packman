package_files = {}
tmp = Dir.glob("#{ENV['PACKMAN_ROOT']}/packages/*.rb")
tmp.delete("#{ENV['PACKMAN_ROOT']}/packages/packman_packages.rb")
tmp.each do |file|
  name = File.basename(file).split('.').first.capitalize.to_sym
  package_files[name] = file
end
# First round (Propagate options from config file to packages).
package_files.each do |name, file|
  load file # Preload the file for package definition.
  if PACKMAN::ConfigManager.packages.has_key? name
    install_spec = PACKMAN::ConfigManager.packages[name]
    if install_spec
      package = PACKMAN::Package.instance name, install_spec
      install_spec.each do |key, value|
        if package.options.has_key? key
          package.options[key] = value
        end
      end
    end
  end
  # Reload the file.
  load file
end
# Second round (Propagate options to dependencies).
package_files.each do |name, file|
  # Propagate options to dependencies.
  if PACKMAN::ConfigManager.packages.has_key? name
    install_spec = PACKMAN::ConfigManager.packages[name]
    if install_spec
      package = PACKMAN::Package.instance name, install_spec
      package.dependencies.each do |depend|
        depend_name = depend.capitalize.to_sym
        depend_package = PACKMAN::Package.instance depend_name
        package.options.each do |key, value|
          if depend_package.options.has_key? key
            depend_package.options[key] = value
            load package_files[depend_name]
          end
        end
      end
    end
  end
end
