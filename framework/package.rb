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

    def self.depends_on(*packages)

    end

    def download_to(root)
      PACKMAN.download(root, url)
    end

    def decompress(root)
      PACKMAN.report_notice "Decompress #{filename}."
      saved_dir = Dir.pwd
      decom_dir = "#{root}/#{self.class}"
      Dir.mkdir(decom_dir) if not Dir.exist?(decom_dir)
      Dir.chdir(decom_dir)
      case PACKMAN.compression_type("#{root}/#{filename}")
      when :tar
        system "tar xf #{root}/#{filename}"
      when :gzip
        system "gzip -d #{root}/#{filename}"
      when :bzip2
        system "bzip2 -d #{root}/#{filename}"
      when :zip
        system "unzip #{root}/#{filename}"
      end
      Dir.chdir(saved_dir)
    end

    def self.prefix(package_self)
      "#{PACKMAN.install_root}/#{package_self.class}/#{package_self.version}/#{PACKMAN.all_compiler_sets.index(@@compiler_set)}"
    end

    # TODO: Use ENV to set compiler environment variables.
    def self.run(cmd, *args)
      cmd_str = ''
      @@compiler_set.each do |language, compiler|
        case language
        when :c
          cmd_str << "CC=#{compiler} "
        when :'c++'
          cmd_str << "CXX=#{compiler} "
        when :fortran
          cmd_str << "FC=#{compiler} "
          cmd_str << "F77=#{compiler} "
        end
      end
      cmd_str << "#{cmd}"
      args.each do |arg|
        cmd_str << " #{arg}"
      end
      system cmd_str
    end

    def self.bashrc(package)
      content = ''
      prefix = prefix(package)
      root = "#{package.class.name.upcase}_ROOT"
      content << "# #{package.sha1}\n"
      content << "export #{root}=#{prefix}\n"
      # Check if 'bin' is provided.
      if Dir.exist?("#{prefix}/bin")
        content << "export PATH=$#{root}/bin:$PATH\n"
      end
      if Dir.exist?("#{prefix}/include")
        content << "export #{package.class.name.upcase}_INCLUDE_PATH=$#{root}/include\n"
      end
      if Dir.exist?("#{prefix}/lib")
        content << "export #{package.class.name.upcase}_LIBRARY_PATH=$#{root}/lib\n"
      end
      f = File.new("#{prefix}/bashrc", 'w')
      f.write(content)
      f.close
    end

    def self.install(compiler_sets, package)
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
            PACKMAN.report_notice "Package #{PACKMAN::Tty.green}#{package.class}#{PACKMAN::Tty.reset} has been installed."
            next
          end
          f.close
        end
        # Install ...
        package.decompress(PACKMAN.package_root)
        tmp = Dir.glob("#{PACKMAN.package_root}/#{package.class}/*")
        if tmp.size != 1 or not File.directory?(tmp.first)
          PACKMAN.report_error "There should be only one directory in \"#{PACKMAN.package_root}/#{package.class}\"!"
        end
        build_dir = tmp.first
        Dir.chdir(build_dir)
        package.install
        Dir.chdir(saved_dir)
        FileUtils.rm_rf("#{build_dir}")
        # Write bashrc file for the package.
        bashrc(package)
      end
      if Dir.exist?("#{PACKMAN.package_root}/#{package.class}")
        FileUtils.rm_rf("#{PACKMAN.package_root}/#{package.class}")
      end
    end
  end
end
