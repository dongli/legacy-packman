module PACKMAN
  class Commands
    def self.relocate
      package_names = CommandLine.packages.uniq
      package_names.each do |package_name|
        package = Package.instance package_name
        PACKMAN.report_notice "Relocate package #{PACKMAN.green package.name}."
        for i in 0..CompilerManager.compiler_sets.size-1
          CompilerManager.activate_compiler_set i
          relocate_package package
        end
      end
    end

    def self.relocate_package package
      depend_packages = Commands.search_dependencies_for package, :instance
      prefix = package.prefix
      Dir.glob("#{package.prefix}/**/*").each do |file|
        next if File.directory? file
        res = `file #{Shellwords.escape file}`
        if res =~ /text/ or res =~ /libtool/
          PACKMAN.replace file, {
            '<packman_prefix>' => prefix,
            '<packman_link_root>' => PACKMAN.link_root
          }, :not_exit
          depend_packages.each do |depend_package|
            PACKMAN.replace file, {
              "<packman_#{depend_package.name}_prefix>" => depend_package.prefix
            }, :not_exit
          end
        elsif File.executable? file
          PACKMAN.os.add_rpath package, file
        end
      end
      package.relocate if package.respond_to? :relocate
    end
  end
end
