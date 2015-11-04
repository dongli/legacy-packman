module PACKMAN
  class Commands
    def self.delegated_methods
      [:is_package_installed?, :install_package]
    end

    def self.search_dependencies_for package, *options
      res = []
      package.dependencies.each do |depend|
        depend_package = Package.instance depend
        res << search_dependencies_for(depend_package, *options)
        if options.include? :instance
          res << depend_package
        else
          res << depend
        end
      end
      res.flatten.uniq
    end

    def self.install
      # Get the package names from command line.
      package_names = CommandLine.packages.uniq
      # Get all the packages that need to be installed including dependencies.
      packages = []
      package_names.each do |package_name|
        package = Package.instance package_name
        next if packages.map { |p| p.class }.include? package.class
        search_dependencies_for(package).each do |depend|
          next if packages.map { |p| p.class.to_s.to_sym }.include? depend
          packages << Package.instance(depend)
        end
        packages << package
      end
      # Install each package.
      packages.each do |package|
        # Binary is preferred.
        if ( package.has_binary? and not package.use_binary? and
           not CommandLine.has_option? '-use_binary') or package.use_binary?
          package = Package.instance package.class, :use_binary => true
        end
        if CommandLine.has_option? '-only_post'
          package.post_install
        else
          install_package package
        end
        if not File.identical? PACKMAN.link_root, PACKMAN.active_root
          PACKMAN.ln PACKMAN.link_root, PACKMAN.active_root, :remove_link_if_exist
        end
      end
    end

    def self.is_package_installed? package, *options
      if File.exist? package.info
        package_hash = Files::Info.read package
        if ( package.sha1 == package_hash[:sha1] and package.revision == package_hash[:revision] ) or
           ( package.use_binary? != package_hash[:use_binary] and package.version == package_hash[:version] )
          if package.check_consistency
            msg = "Package #{CLI.green package.name} has been installed"
            if not package.use_binary? and not package.has_label? :compiler_insensitive
              msg << " by using compiler set #{CLI.green CompilerManager.active_compiler_set_index}"
            end
            CLI.report_notice msg+'.' if not options.include? :silent
            # Propagate options in info file to package.
            package_hash.each { |key, value| package.update_option key, value, true }
            # TODO: Clean this.
            # When there is any dependency use MPI, we should use MPI for the package.
            if not package.use_binary? and package.has_option? :use_mpi and package.use_mpi?
              PACKMAN.use_mpi package.mpi
            end
            return true
          end
        end
      elsif package.respond_to? :installed? and package.installed?
        return true
      end
      return false
    end

    def self.install_package package, *options
      # Check if the package should be skipped.
      if package.should_be_skipped? or
        (not package.has_label? :master_package and
         not package.methods.include? :install and
         not package.use_binary?)
        if not package.methods.include? :installed?
          CLI.report_error "Package #{CLI.red package.name} does not have #{CLI.blue 'installed?'} method!"
        end
        if not package.installed?
          if not package.methods.include? :install
            CLI.report_error "Package #{CLI.red package.name} "+
              "should be provided by system!\n#{CLI.blue '==>'} "+
              "The possible installation method is:\n#{package.install_method}"
          end
        else
          return
        end
      end
      # Check if the package is a master.
      if package.has_label? :master_package and not package.respond_to? :install
        CLI.report_notice "Package master #{CLI.green package.name} has been installed."
        return
      end
      # Check if the package has already installed.
      return if is_package_installed?(package, *options) and not CommandLine.has_option? '-force'
      # Check if the package has been downloaded or not. If not, download it when
      # the OS is connected with internet.
      begin
        PACKMAN.download_package package, :skip_depend_packages
      rescue => e
        if not NetworkManager.is_connect_internet?
          PACKMAN.report_error "#{PACKMAN.red package.filename} has not been downloaded!\n" +
            "#{PACKMAN.red '==>'} #{e}"
        elsif package.use_binary? and not package.has_label? :external_binary
          PACKMAN.report_warning "#{PACKMAN.red package.filename} is not available! Compile it from source.\n"
          package = Package.instance package.class
          retry
        end
      end
      # Install package.
      if package.use_binary?
        # Install precompiled package.
        prefix = PACKMAN.prefix package
        # Use precompiled binary file.
        CLI.report_notice "Use precompiled binary files for #{CLI.green package.name}."
        PACKMAN.mkdir prefix, :force
        PACKMAN.cd prefix
        PACKMAN.decompress "#{ConfigManager.package_root}/#{package.filename}"
        PACKMAN.cd_back
        Files::Info.write package
        package.post_install
        start_handle_new_compiler_set package
        link_package package
        relocate_package package if not package.has_label? :binary
        stop_handle_new_compiler_set package
      else
        # Build package for each compiler set.
        build_upper_dir = "#{ConfigManager.package_root}/#{package.name}"
        # Decompress package file.
        if package.is_compressed?
          package.decompress_to ConfigManager.package_root
        else
          package.copy_to ConfigManager.package_root
        end
        tmp = Dir.glob("#{build_upper_dir}/*")
        if tmp.size != 1 or not File.directory? tmp.first
          tmp = ["#{build_upper_dir}"]
        end
        build_dir = tmp.first
        PACKMAN.cd build_dir
        # Apply patches.
        Package.apply_patch package
        # Install package.
        CLI.report_notice "Install package #{CLI.green package.name} with compiler set #{CLI.green CompilerManager.active_compiler_set_index}."
        package.install
        PACKMAN.cd_back
        FileUtils.rm_rf build_dir
        Files::Info.write package
        package.post_install
        handle_new_compiler_set package
        link_package package
        repair_dynamic_links package if not package.has_label? :binary
        FileUtils.rm_rf build_upper_dir if Dir.exist? build_upper_dir
      end
      # Clean shell environment.
      PACKMAN.clear_env
    end

    def self.link_package package
      return if not Dir.exist? package.prefix
      if package.has_label? :unlinked
        PACKMAN.report_warning "Package #{PACKMAN.green package.name} is not linked!"
        return
      end
      if package.has_label? :compiler_insensitive and not package.has_label? :compiler_set
        for i in 0..CompilerManager.compiler_sets.size-1
          CompilerManager.activate_compiler_set i
          Commands.link package.name
        end
        CompilerManager.activate_compiler_set ConfigManager.defaults[:compiler_set_index]
      else
        Commands.link package.name
      end
    end

    def self.repair_dynamic_links package
      prefix = package.prefix
      return if not Dir.exist? prefix
      PACKMAN.report_notice "Repair dynamic links in #{PACKMAN.green package.name}."
      Dir.glob("#{prefix}/**/*").each do |file|
        next if File.directory? file or File.symlink? file
        if File.executable? file or PACKMAN.os.is_dynamic_library? file
          PACKMAN.os.repair_dynamic_link package, file
          PACKMAN.os.add_rpath package, file
        end
      end
    end

    def self.handle_new_compiler_set package
      if package.has_label? :compiler_set
        command_hash = { :installed_by_packman => package.name }
        package.provided_stuffs.each do |language, compiler|
          command_hash[language] = "#{package.bin}/#{compiler}"
        end
        CompilerManager.add_compiler_set command_hash
        CompilerManager.activate_compiler_set CompilerManager.compiler_sets.size-1
        ConfigManager.write
        CompilerManager.activate_compiler_set ConfigManager.defaults[:compiler_set_index]
      end
    end
  end
end
