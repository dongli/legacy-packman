module PACKMAN
  class Commands
    def self.link *package_names
      package_names = CommandLine.packages.uniq if package_names.empty?
      inventory = Files::Inventory.new
      package_names.each do |package_name|
        package = Package.instance package_name
        next if package.has_label? :installed_with_source or inventory.include? package or package.has_label? :unlinked
        inventory.add package
        next if not File.directory? package.prefix
        PACKMAN.report_notice "Link #{PACKMAN.green package_name} for compiler set #{PACKMAN.green CompilerManager.active_compiler_set_index}."
        regex = /#{package.prefix}\/?(.*)/
        Dir.glob("#{package.prefix}/**/*").each do |file_path|
          path = Pathname.new file_path
          next if path.directory? or path.basename.to_s =~ /packman\..*/
          dir_struct = path.dirname.to_s.match(regex)[1]
          PACKMAN.mkdir "#{PACKMAN.link_root}/#{dir_struct}", :skip_if_exist, :silent
          PACKMAN.ln file_path, "#{PACKMAN.link_root}/#{dir_struct}/"
        end
      end
    end
  end
end
