Dir.glob("#{ENV['PACKMAN_ROOT']}/packages/*.rb").each do |file|
  next if file =~ /packman_packages.rb$/
  # Propagate options in configuration file to package.
  load file # Preload the file for package definition.
  package_name = File.basename(file).split('.').first.capitalize.to_sym
  if PACKMAN::ConfigManager.packages.has_key? package_name
    install_spec = PACKMAN::ConfigManager.packages[package_name]
    if install_spec
      package = PACKMAN::Package.instance package_name, install_spec
      install_spec.each do |key, value|
        if package.options.has_key? key
          package.options[key] = value
        end
      end
    end
  end
  # Actually load the file.
  require file
end
