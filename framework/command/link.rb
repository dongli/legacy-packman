module PACKMAN
  def self.not_link file_path
    @@not_linked_file_paths ||= []
    @@not_linked_file_paths << file_path
    @@not_linked_file_paths.uniq!
  end

  def self.should_not_link? file_path
    @@not_linked_file_paths ||= []
    @@not_linked_file_paths.each do |not_linked_file_path|
      return true if file_path =~ /#{not_linked_file_path}/
    end
    false
  end

  class Commands
    def self.link *package_names
      package_names = CommandLine.packages.uniq if package_names.empty?
      inventory = Files::Inventory.new
      package_names.each do |package_name|
        package = Package.instance package_name
        next if package.has_label? :unlinked
        next if not File.directory? package.prefix
        package.before_link
        PACKMAN.report_notice "Link #{PACKMAN.green package_name} for compiler set #{PACKMAN.green CompilerManager.active_compiler_set_index}."
        regex = /#{package.prefix}\/?(.*)/
        Dir.glob("#{package.prefix}/**/*").each do |file_path|
          next if PACKMAN.should_not_link? file_path
          path = Pathname.new file_path
          next if path.directory? or path.basename.to_s =~ /packman\..*/
          dir_struct = path.dirname.to_s.match(regex)[1]
          PACKMAN.mkdir "#{PACKMAN.link_root}/#{dir_struct}", :skip_if_exist, :silent
          PACKMAN.ln file_path, "#{PACKMAN.link_root}/#{dir_struct}/"
        end
        inventory.add package
      end
    end
  end
end
