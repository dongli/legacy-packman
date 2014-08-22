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
      if source == :INLINE
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
        self.class_eval("@@inline_patches ||= []; @@inline_patches << patch")
        self.class_eval("def inline_patches; @@inline_patches; end")
      else
        self.class_eval("@@patches ||= []; @@patches << [ source, sha1 ]")
        self.class_eval("def patches; @@patches; end")
      end
    end

    def depends; []; end

    def labels; []; end

    def patches; []; end

    def inline_patches; []; end

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

    def self.apply_patch(package)
        for i in 0..package.patches.size-1
          PACKMAN.report_notice "Apply patch #{ConfigManager.package_root}/#{package.class}.patch.#{i}"
          patch_file = "#{ConfigManager.package_root}/#{package.class}.patch.#{i}"
          PACKMAN.run "patch -N -Z -p1 < #{patch_file}"
        end
        package.inline_patches.each do |patch|
          PACKMAN.report_notice "Apply inline patch."
          IO.popen("/usr/bin/patch --ignore-whitespace -N -Z -p1", "w") { |p| p.write(patch) }
          if not $?.success?
            PACKMAN.report_error "Failed to apply inline patch for #{PACKMAN::Tty.red}#{package.class}#{PACKMAN::Tty.reset}!"
          end
        end
    end

    def self.install(compiler_sets, package, is_recursive = false)
      # Check dependencies.
      package.depends.each do |depend|
        depend_package = eval "#{depend.capitalize}.new"
        install(compiler_sets, depend_package, true)
        RunManager.append_bashrc_path("#{prefix(depend_package)}/bashrc")
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
