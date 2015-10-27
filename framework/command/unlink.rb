module PACKMAN
  class Commands
    def self.unlink *package_names
      package_names = CommandLine.packages.uniq if package_names.empty?
      inventory = Files::Inventory.new
      package_names.each do |package_name|
        package = Package.instance package_name
        next if not inventory.include? package
        next if not File.directory? package.prefix
        package.before_link
        regex = /#{package.prefix}\/?(.*)/
        PACKMAN.report_notice "Unlink #{PACKMAN.green package_name} for compiler set #{PACKMAN.green CompilerManager.active_compiler_set_index}."
        Dir.glob("#{package.prefix}/**/*").each do |file_path|
          next if PACKMAN.should_not_link? file_path
          path = Pathname.new file_path
          next if path.directory?
          dir_struct = path.dirname.to_s.match(regex)[1]
          PACKMAN.rm "#{PACKMAN.link_root}/#{dir_struct}/#{path.basename}"
          Pathname.new(dir_struct).ascend do |a|
            dir = "#{PACKMAN.link_root}/#{a}"
            next if not Dir.glob("#{dir}/*").empty?
            PACKMAN.rm dir
          end
        end
        inventory.remove package
      end
    end
  end
end
