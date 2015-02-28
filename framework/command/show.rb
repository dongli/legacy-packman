module PACKMAN
  class Commands
    def self.show
      CommandLine.packages.each do |package_name|
        package = Package.instance package_name
        if CommandLine.has_option? '-options'
          CLI.report_notice "Options of package #{CLI.green package_name}:"
          record_options package
          if package.has_label? 'master_package'
            package.dependencies.each do |depend_package_name|
              depend_package = Package.instance depend_package_name
              record_options depend_package
            end
          end
          @@options.each do |option_name, option_type_or_default|
            print "#{CLI.blue option_name}: #{CLI.yellow "#{option_type_or_default}"}\n"
          end
        end
      end
    end

    def self.record_options package
      @@options ||= {}
      package.options.each do |key, value|
        next if @@options.has_key? key
        if value != nil
          @@options[key] = value
        else
          if package.option_valid_types[key].class == Array
            @@options[key] = package.option_valid_types[key].join(' or ')
          else
            @@options[key] = package.option_valid_types[key]
          end
        end
      end
    end
  end
end