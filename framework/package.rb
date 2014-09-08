module PACKMAN
  class Package
    def self.url(val)
      self.class_eval("def url; '#{val}'; end")
      self.class_eval("def filename; '#{File.basename(URI.parse(val).path)}'; end")
    end

    def self.sha1(val)
      self.class_eval("def sha1; '#{val}'; end")
    end

    def self.git(val)
      self.class_eval("def git; '#{val}'; end")
      self.class_eval("def dirname; '#{File.basename(URI.parse(val).path).gsub(/\.git$/, '')}'; end")
    end

    def self.tag(val)
      self.class_eval("def tag; '#{val}'; end")
    end

    def self.version(val)
      self.class_eval("def version; '#{val}'; end")
    end

    def self.filename(val)
      self.class_eval("def filename; '#{val}'; end")
    end

    def self.dirname(val)
      self.class_eval("def dirname; '#{val}'; end")
    end

    def self.depends_on(package)
      self.class_eval("@@depends ||= []; @@depends.push package")
      self.class_eval("def depends; @@depends; end")
    end

    def self.label(label)
      self.class_eval("@@labels ||= []; @@labels.push label")
      self.class_eval("def labels; @@labels; end")
    end

    def self.provide(stuff)
      self.class_eval("@@stuffs ||= {}; @@stuffs.merge! stuff")
      self.class_eval("def stuffs; @@stuffs; end")
    end

    def self.skip_on(distro)
      self.class_eval("@@skip_distros ||= []; @@skip_distros.push distro.to_sym")
      self.class_eval("def skip_distros; @@skip_distros; end")
    end

    def self.conflicts_with(package)
      self.class_eval("@@conflict_packages ||= []; @@conflict_packages.push package.capitalize")
      self.class_eval("def conflict_packages; @@conflict_packages; end")
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

    def self.attach(source, sha1)
      self.class_eval("@@attaches ||= []; @@attaches << [ source, sha1 ]")
      self.class_eval("def attaches; @@attaches; end")
    end

    def self.apply_patch(package)
        for i in 0..package.patches.size-1
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

    def stuffs; {}; end

    def skip_distros; []; end

    def conflict_packages; []; end

    def patches; []; end

    def attaches; []; end

    def embeded_patches; []; end

    def postfix; end

    def download_to(root)
      if self.respond_to? :url
        package_file = "#{root}/#{filename}"
        if File.exist? package_file
          return if PACKMAN.sha1_same? package_file, sha1
        end
        PACKMAN.report_notice "Download package #{Tty.red}#{self.class}#{Tty.reset}."
        PACKMAN.download(root, url, filename)
      elsif self.respond_to? :git
        package_dir = "#{root}/#{dirname}"
        if Dir.exist? package_dir
          return if PACKMAN.sha1_same? package_dir, sha1
        end
        PACKMAN.report_notice "Download package #{Tty.red}#{self.class}#{Tty.reset}."
        PACKMAN.git_clone(root, git, tag, dirname)
      end
    end

    def skip?
      skip_distros.include? PACKMAN::OS.distro or
      skip_distros.include? :all or
      labels.include? 'should_provided_by_system' or
      ( labels.include? 'use_system_first' and installed? )
    end

    def decompress_to(root)
      PACKMAN.report_notice "Decompress #{filename}."
      if not File.exist? "#{root}/#{filename}"
        PACKMAN.report_error "Package #{Tty.red}#{self.class}#{Tty.reset} has not been downloaded!"
      end
      saved_dir = Dir.pwd
      decom_dir = "#{root}/#{self.class}"
      PACKMAN.mkdir(decom_dir, :force)
      Dir.chdir(decom_dir)
      PACKMAN.decompress "#{root}/#{filename}"
      Dir.chdir(saved_dir)
    end

    def copy_to(root)
      PACKMAN.report_notice "Copy #{dirname}."
      if not Dir.exist? "#{root}/#{dirname}"
        PACKMAN.report_error "Package #{Tty.red}#{self.class}#{Tty.reset} has not been downloaded!"
      end
      copy_dir = "#{root}/#{self.class}"
      PACKMAN.mkdir(copy_dir, :force)
      PACKMAN.cp "#{root}/#{dirname}", copy_dir
    end

    def self.prefix(package_self)
      if package_self.class == Class or package_self.class == String
        package_self = PACKMAN.new_class package_self
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
      class_name = package.class.name.upcase
      root = "#{class_name}_ROOT"
      open("#{prefix}/bashrc", "w") do |file|
        file << "# #{package.sha1}\n"
        file << "export #{root}=#{prefix}\n"
        if Dir.exist?("#{prefix}/bin")
          file << "export PATH=$#{root}/bin:$PATH\n"
        end
        if Dir.exist?("#{prefix}/share/man")
          file << "export MANPATH=\"$#{root}/share/man:$MANPATH\"\n"
        end
        if Dir.exist?("#{prefix}/include")
          file << "export #{class_name}_INCLUDE=\"-I$#{root}/include\"\n"
        end
        libs = []
        if Dir.exist?("#{prefix}/lib")
          libs << "$#{root}/lib"
        end
        if Dir.exist?("#{prefix}/lib64")
          libs << "$#{root}/lib64"
        end
        if not libs.empty?
          file << "export #{class_name}_LIBRARY=\"-L#{libs.join(' -L')}\"\n"
          file << "export #{PACKMAN::OS.ld_library_path_name}=#{libs.join(':')}:$#{PACKMAN::OS.ld_library_path_name}\n"
          file << "export #{class_name}_RPATH=\"-Wl,-rpath,#{libs.join(',-rpath,')}\"\n"
        end
        if Dir.exist?("#{prefix}/lib/pkgconfig")
          file << "export PKG_CONFIG_PATH=$#{root}/lib/pkgconfig:$PKG_CONFIG_PATH\n"
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

    def install_method
      "Not available!"
    end

    def self.install(compiler_sets, package, is_recursive = false)
      # Check dependencies.
      package.depends.each do |depend|
        depend_package = PACKMAN.new_class depend.capitalize
        install(compiler_sets, depend_package, true)
        if not depend_package.skip?
          RunManager.append_bashrc_path("#{prefix(depend_package)}/bashrc")
        end
      end
      # Check if the package should be skipped.
      if package.skip?
        if not package.skip_distros.include? :all and not package.installed?
          PACKMAN.report_error "Package #{PACKMAN::Tty.red}#{package.class}#{PACKMAN::Tty.reset} "+
            "should be provided by system!\n#{PACKMAN::Tty.blue}==>#{PACKMAN::Tty.reset} "+
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
        # Decompress package file.
        if package.respond_to? :filename
          package.decompress_to ConfigManager.package_root
        elsif package.respond_to? :dirname
          package.copy_to ConfigManager.package_root
        end          
        tmp = Dir.glob("#{ConfigManager.package_root}/#{package.class}/*")
        if tmp.size != 1 or not File.directory?(tmp.first)
          tmp = ["#{ConfigManager.package_root}/#{package.class}"]
        end
        build_dir = tmp.first
        Dir.chdir(build_dir)
        # Apply patches.
        apply_patch(package)
        # Install package.
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
