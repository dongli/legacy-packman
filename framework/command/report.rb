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
      else
        if not File.exist? "#{ENV['PACKMAN_ROOT']}/.version"
          CLI.report_error "Version is missing!"
        end
        current_version = File.open("#{ENV['PACKMAN_ROOT']}/.version", 'r').read.strip
        print "#{CLI.green 'packman'} #{CLI.bold current_version} "
        print "(Report BUG or ADVICE to #{CLI.bold 'https://github.com/dongli/packman/issues'})\n"
      end
    end
  end
end
