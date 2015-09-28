module PACKMAN
  class Commands
    def self.unlink *package_names
      if package_names.empty?
        package_names = CommandLine.packages.empty? ? ConfigManager.package_options.keys : CommandLine.packages.uniq
      end
      if not CompilerManager.active_compiler_set_index
        CompilerManager.activate_compiler_set ConfigManager.defaults['compiler_set_index']
      end
      link_root = "#{ConfigManager.install_root}/#{CompilerManager.active_compiler_set_index}"
      inventory = Files::Inventory.new link_root
      package_names.each do |package_name|
        package = Package.instance package_name
        next if package.has_label? :installed_with_source or not inventory.include? package
        regex = /#{package.prefix}\/?(.*)/
        PACKMAN.report_notice "Unlink #{PACKMAN.green package_name} for compiler set #{PACKMAN.green CompilerManager.active_compiler_set_index}."
        Dir.glob("#{package.prefix}/**/*").each do |file_path|
          path = Pathname.new file_path
          next if path.directory?
          dir_struct = path.dirname.to_s.match(regex)[1]
          PACKMAN.rm "#{link_root}/#{dir_struct}/#{path.basename}"
          Pathname.new(dir_struct).ascend do |a|
            dir = "#{link_root}/#{a}"
            next if not Dir.glob("#{dir}/*").empty?
            PACKMAN.rm dir
          end
        end
        inventory.remove package
      end
    end
  end
end
