module PACKMAN
  class Commands
    def self.link *package_names
      if package_names.empty?
        if CommandLine.packages.empty?
          package_names = ConfigManager.package_options.keys
          link_depends = true
        else
          package_names = CommandLine.packages.uniq
          link_depends = false
        end
      end
      if not CompilerManager.active_compiler_set_index
        CompilerManager.activate_compiler_set ConfigManager.defaults['compiler_set_index']
      end
      link_root = "#{ConfigManager.install_root}/#{CompilerManager.active_compiler_set_index}"
      inventory = Files::Inventory.new link_root
      package_names.each do |package_name|
        package = Package.instance package_name
        next if package.has_label? :installed_with_source or inventory.include? package
        inventory.add package
        package.dependencies.each { |depend| link depend } if link_depends
        PACKMAN.report_notice "Link #{PACKMAN.green package_name} for compiler set #{PACKMAN.green CompilerManager.active_compiler_set_index}."
        regex = /#{package.prefix}\/?(.*)/
        Dir.glob("#{package.prefix}/**/*").each do |file_path|
          path = Pathname.new file_path
          next if path.directory? or path.basename.to_s =~ /packman\..*/
          dir_struct = path.dirname.to_s.match(regex)[1]
          PACKMAN.mkdir "#{link_root}/#{dir_struct}", :skip_if_exist, :silent
          PACKMAN.ln file_path, "#{link_root}/#{dir_struct}/"
        end
      end
    end
  end
end
