module PACKMAN
  module Storage
    PROVIDER = :Bintray

    def self.init
      eval "Storage::#{PROVIDER}.init"
    end

    def self.label package, os = nil, compiler_set = nil
      os ||= PACKMAN.os
      compiler_set ||= PACKMAN.active_compiler_set
      res = []
      res << "#{package.name}-#{package.version}"
      res << "#{os.type.downcase}-#{os.version.major_minor}"
      if not package.has_label? :compiler_set
        compiler_set.compilers.each do |language, compiler|
          res << "#{language}-#{compiler.vendor}-#{compiler.version.major_minor}"
        end
      end
      res.join('_')
    end

    def self.file_name package, os = nil, compiler_set = nil
      "#{label package, os, compiler_set}.tgz"
    end

    def self.pack package, os = nil, compiler_set = nil
      depend_packages = Commands.search_dependencies_for package, :instance
      PACKMAN.report_error "Active compiler set is not set!" if not CompilerManager.active_compiler_set_index
      prefix = package.prefix
      path = "#{ConfigManager.package_root}/#{file_name package, os, compiler_set}"
      # Replace any special path in package with a placeholder for later query.
      tmp_dir = "#{ConfigManager.package_root}/#{package.name}"
      PACKMAN.rm tmp_dir
      PACKMAN.mkdir tmp_dir, :silent
      PACKMAN.cp "#{prefix}/*", tmp_dir
      Dir.glob("#{tmp_dir}/**/*").each do |file|
        next if File.directory? file or File.symlink? file
        res = `file #{file}`
        if res =~ /text/ or res =~ /libtool/
          PACKMAN.replace file, {
            prefix => '<packman_prefix>',
            PACKMAN.link_root => '<packman_link_root>'
          }, :not_exit
          depend_packages.each do |depend_package|
            PACKMAN.replace file, {
              depend_package.prefix => "<packman_#{depend_package.name}_prefix>"
            }, :not_exit
          end
        elsif File.executable? file or PACKMAN.os.is_dynamic_library? file
          PACKMAN.os.delete_rpath package, file
        end
      end
      # Compress package.
      PACKMAN.work_in tmp_dir do
        PACKMAN.compress '.', path, :silent
      end
      PACKMAN.rm tmp_dir
      path
    end

    def self.url package, os = nil, compiler_set = nil
      case PROVIDER
      when :Bintray
        "https://bintray.com/artifact/download/packman/binary/#{file_name package, os, compiler_set}"
      end
    end

    def self.is_authenticated?
      eval "Storage::#{PROVIDER}.is_authenticated?"
    end

    def self.upload package
      path = Storage.pack package
      eval "Storage::#{PROVIDER}.upload package, path"
    end
  end
end
