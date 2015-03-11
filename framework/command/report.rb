module PACKMAN
  class Commands
    def self.report
      if CommandLine.has_option? '-compiler_sets'
        ConfigManager.print_compiler_sets
      elsif CommandLine.has_option? '-package_root'
        print "#{ConfigManager.package_root}\n"
      elsif CommandLine.has_option? '-install_root'
        print "#{ConfigManager.install_root}\n"
      elsif CommandLine.has_option? '-installed_packages'
        Dir.glob("#{ConfigManager.install_root}/*").each do |package_root|
          package_name = File.basename package_root
          next if not Package.all_package_names.include? package_name
          versions = Dir.glob("#{package_root}/*").sort.map { |x| File.basename x }
          sets = []
          Dir.glob("#{package_root}/*").each do |dir|
            sets << Dir.glob("#{dir}/*").sort.map { |x| File.basename x }
            sets.last.delete_if { |x| not PACKMAN.integer? x or not (0..CompilerManager.compiler_sets.size-1).include? Integer(x) }
          end
          print "#{CLI.green package_name}: "
          version_set_pairs = []
          for i in 0..versions.size-1
            if sets[i].empty?
              version_set_pairs << "#{CLI.blue versions[i]}"
            else
              version_set_pairs << "#{CLI.blue versions[i]} #{sets[i]}"
            end
          end
          print "#{version_set_pairs.join(" | ")}\n"
        end
      elsif CommandLine.has_option? '-package_options'
        CommandLine.packages.each do |package_name|
          package = Package.instance package_name
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
      else
        if not File.exist? "#{ENV['PACKMAN_ROOT']}/.version"
          CLI.report_error "Version is missing!"
        end
        current_version = File.open("#{ENV['PACKMAN_ROOT']}/.version", 'r').read.strip
        print "#{CLI.green 'packman'} #{CLI.bold current_version} "
        print "(Report BUG or ADVICE to #{CLI.bold 'https://github.com/dongli/packman/issues'})\n"
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
