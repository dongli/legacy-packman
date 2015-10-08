module PACKMAN
  module Files
    class Info
      def self.extract_from package
        hash = {
          :sha1 => package.sha1,
          :version => package.version,
          :revision => package.revision,
          :use_binary => package.use_binary?,
          :os => PACKMAN.os.to_hash
        }
        hash[:compiler_set] = CompilerManager.active_compiler_set ? CompilerManager.active_compiler_set.to_hash : {}
        return hash
      end

      def self.write package, *options
        prefix = PACKMAN.prefix package, *options
        return if not Dir.exist? prefix
        info_path = "#{prefix}/packman.info"
        package_hash = File.exist?(info_path) ? eval(File.open(info_path, 'r').read) : {}
        package_name = package.name.to_sym
        eval "package_hash[package_name] = extract_from package"
        eval "package_hash[package_name][:dependencies] = {}"
        package.dependencies.each do |depend|
          depend_package = Package.instance depend
          depend_hash = read depend_package, *options
          next if not depend_hash
          eval "package_hash[package_name][:dependencies][depend_package.name.to_sym] = depend_hash"
        end
        File.open(info_path, 'w') do |file|
          PP.pp package_hash, file
        end
      end

      def self.read package, *options
        prefix = PACKMAN.prefix package, *options
        return nil if package.should_be_skipped?
        PACKMAN.report_error "Package #{PACKMAN.red package.name} has not been installed!" if not Dir.exist? prefix
        info_path = "#{prefix}/packman.info"
        begin
          package_hash = eval File.open(info_path, 'r').read
        rescue SyntaxError => e
          package_hash = nil
        end
        # Avoid potential problems.
        package_name = package.name.to_sym
        package_hash = { package_name => {} } if not package_hash
        package_hash[package_name]
      end
    end
  end
end
