module PACKMAN
  class Package
    def self.url(val)
      self.class_eval("def url; '#{val}'; end")
      self.class_eval("def filename; '#{File.basename(URI.parse(val).path)}'; end")
    end

    def self.sha1(val)
      self.class_eval("def sha1; '#{val}'; end")
    end

    def self.version(val)
      self.class_eval("def version; '#{val}'; end")
    end

    def self.filename(val)
      self.class_eval("def filename; '#{val}'; end")
    end

    def self.depends_on(package)
      self.class_eval("@@depends ||= []; @@depends.push package")
      self.class_eval("def depends; @@depends; end")
    end

    def self.label(label)
      self.class_eval("@@labels ||= []; @@labels.push label")
      self.class_eval("def labels; @@labels; end")
    end

    def self.patch(source, sha1 = nil)
      if source == :embeded
        patch = ''
        start = false
        File.open("#{ENV['PACKMAN_ROOT']}/packages/#{self.to_s.downcase}.rb", 'r').each do |line|
          if line =~ /__END__/
            start = true
            next
          end
          if start
            patch << line
          end
        end
        self.class_eval("@@embeded_patches ||= []; @@embeded_patches << patch")
        self.class_eval("def embeded_patches; @@embeded_patches; end")
      else
        self.class_eval("@@patches ||= []; @@patches << [ source, sha1 ]")
        self.class_eval("def patches; @@patches; end")
      end
    end

    def self.apply_patch(package)
        for i in 0..package.patches.size-1
          PACKMAN.report_notice "Apply patch #{ConfigManager.package_root}/#{package.class}.patch.#{i}"
          patch_file = "#{ConfigManager.package_root}/#{package.class}.patch.#{i}"
          PACKMAN.run "patch -N -Z -p1 < #{patch_file}"
          if not $?.success?
            PACKMAN.report_error "Failed to apply patch for #{PACKMAN::Tty.red}#{package.class}#{PACKMAN::Tty.reset}!"
          end
        end
        package.embeded_patches.each do |patch|
          PACKMAN.report_notice "Apply embeded patch."
          IO.popen("/usr/bin/patch --ignore-whitespace -N -Z -p1", "w") { |p| p.write(patch) }
          if not $?.success?
            PACKMAN.report_error "Failed to apply embeded patch for #{PACKMAN::Tty.red}#{package.class}#{PACKMAN::Tty.reset}!"
          end
        end
    end

    def depends; []; end

    def labels; []; end

    def patches; []; end

    def embeded_patches; []; end

    def postfix; end

    def download_to(root)
      PACKMAN.download(root, url, filename)
    end

    def decompress(root)
      PACKMAN.report_notice "Decompress #{filename}."
      if not File.exist?("#{root}/#{filename}")
        PACKMAN.report_error "File #{Tty.red}#{filename}#{Tty.reset} has not been downloaded!"
      end
      saved_dir = Dir.pwd
      decom_dir = "#{root}/#{self.class}"
      PACKMAN.mkdir(decom_dir, :force)
      Dir.chdir(decom_dir)
      case PACKMAN.compression_type("#{root}/#{filename}")
      when :tar
        system "tar xf #{root}/#{filename}"
      when :gzip
        system "gzip -d #{root}/#{filename}"
      when :bzip2
        system "bzip2 -d #{root}/#{filename}"
      when :zip
        system "unzip -o #{root}/#{filename} 1> /dev/null"
      end
      Dir.chdir(saved_dir)
    end

    def self.prefix(package_self)
      if package_self.class == Class or package_self.class == String
        package_self = eval "#{package_self}.new"
      end
      prefix = "#{ConfigManager.install_root}/#{package_self.class.to_s.downcase}/#{package_self.version}"
      if not package_self.labels.include? 'compiler'
        compiler_set_index = ConfigManager.compiler_sets.index(Package.compiler_set)
        prefix << "/#{compiler_set_index}"
      end
      return prefix
    end

    def self.compiler_set
      @@compiler_set
    end

    def self.bashrc(package)
      prefix = prefix(package)
      root = "#{package.class.name.upcase}_ROOT"
      open("#{prefix}/bashrc", "w") do |file|
        file << "# #{package.sha1}\n"
        file << "export #{root}=#{prefix}\n"
        if Dir.exist?("#{prefix}/bin")
          file << "export PATH=$#{root}/bin:$PATH\n"
        end
        if Dir.exist?("#{prefix}/share/man")
          file << "export MANPATH=$#{root}/share/man:$MANPATH\n"
        end
        if Dir.exist?("#{prefix}/include")
          file << "export #{package.class.name.upcase}_INCLUDE_PATH=$#{root}/include\n"
        end
        if Dir.exist?("#{prefix}/lib")
          file << "export #{package.class.name.upcase}_LIBRARY_PATH=$#{root}/lib\n"
          case OS.type
          when :Darwin
            file << "export DYLD_LIBRARY_PATH=$#{root}/lib:$DYLD_LIBRARY_PATH"
          when :Linux
            file << "export LD_LIBRARY_PATH=$#{root}/lib:$LD_LIBRARY_PATH"
          end
        end
        if Dir.exist?("#{prefix}/lib64")
          case OS.type
          when :Darwin
            file << "export DYLD_LIBRARY_PATH=$#{root}/lib64:$DYLD_LIBRARY_PATH"
          when :Linux
            file << "export LD_LIBRARY_PATH=$#{root}/lib64:$LD_LIBRARY_PATH"
          end
        end
        if Dir.exist?("#{prefix}/lib/pkgconfig")
          file << "export PKG_CONFIG_PATH=$#{root}/lib/pkgconfig:$PKG_CONFIG_PATH"
        end
      end
    end

    def self.default_cmake_args(package)
      %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix(package)}
        -DCMAKE_BUILD_TYPE=None
        -DCMAKE_FIND_FRAMEWORK=LAST
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -Wno-dev
      ]
    end

    def create_cmake_config(name, include_dirs, libraries)
      prefix = Package.prefix(self)
      if not Dir.exist? "#{prefix}/include" or not Dir.exist? "#{prefix}/lib"
        PACKMAN.report_error "Nonstandard package #{PACKMAN::Tty.red}#{self.class}#{PACKMAN::Tty.reset} without \"include\" or \"lib\" directories!"
      end
      if Dir.exist? "#{prefix}/lib/cmake"
        PACKMAN.report_error "Cmake configure file has alreadly been installed for #{PACKMAN::Tty.red}#{self.class}#{PACKMAN::Tty.reset}!"
      end
      PACKMAN.mkdir "#{prefix}/lib/cmake"
      File.open("#{prefix}/lib/cmake/#{self.class.to_s.downcase}-config.cmake", 'w') do |file|
        file << "set (#{name}_INCLUDE_DIRS"
        case include_dirs.class
        when Array
          include_dirs.each { |dir| file << " #{dir}" }
        when String
          file << include_dirs
        end
        file << ")\n"
        file << "set (#{name}_LIBRARIES"
        case libraries.class
        when Array
          libraries.each { |lib| file << " #{lib}" }
        when String
          file << libraries
        end
        file << ")\n"
      end
    end

    def self.install(compiler_sets, package, is_recursive = false)
      # Check dependencies.
      package.depends.each do |depend|
        depend_package = eval "#{depend.capitalize}.new"
        install(compiler_sets, depend_package, true)
        if not depend_package.labels.include?('should_provided_by_system')
          RunManager.append_bashrc_path("#{prefix(depend_package)}/bashrc")
        end
      end
      # Check if the package is provided by system.
      if package.labels.include?('should_provided_by_system')
        if not package.installed?
          PACKMAN.report_error "Package #{PACKMAN::Tty.red}#{package.class}#{PACKMAN::Tty.reset} should be provided by system! "+
            "The possible installation method is:\n#{package.install_method}"
        end
        return
      end
      saved_dir = Dir.pwd
      # Build package for each compiler set.
      compiler_sets.each do |compiler_set|
        @@compiler_set = compiler_set
        # Check if the package has alreadly installed.
        bashrc = "#{prefix(package)}/bashrc"
        if File.exist?(bashrc)
          f = File.new(bashrc, 'r')
          first_line = f.readline
          if first_line =~ /#{package.sha1}/
            if not is_recursive
              PACKMAN.report_notice "Package #{PACKMAN::Tty.green}#{package.class}#{PACKMAN::Tty.reset} has been installed."
            end
            next
          end
          f.close
        end
        # Install ...
        package.decompress(ConfigManager.package_root)
        tmp = Dir.glob("#{ConfigManager.package_root}/#{package.class}/*")
        if tmp.size != 1 or not File.directory?(tmp.first)
          PACKMAN.report_error "There should be only one directory in \"#{ConfigManager.package_root}/#{package.class}\"!"
        end
        build_dir = tmp.first
        Dir.chdir(build_dir)
        # Apply patches.
        apply_patch(package)
        PACKMAN.report_notice "Install package #{Tty.green}#{package.class}#{Tty.reset}."
        package.install
        Dir.chdir(saved_dir)
        FileUtils.rm_rf("#{build_dir}")
        # Write bashrc file for the package.
        bashrc(package)
        package.postfix
      end
      if Dir.exist?("#{ConfigManager.package_root}/#{package.class}")
        FileUtils.rm_rf("#{ConfigManager.package_root}/#{package.class}")
      end
      # Clean the bashrc pathes.
      if not is_recursive
        RunManager.clean_bashrc_path
      end
    end
  end
end
