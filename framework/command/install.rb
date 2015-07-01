module PACKMAN
  class Commands
    def self.delegated_methods
      [:is_package_installed?, :install_package]
    end

    def self.installed_packages
      @@installed_packages ||= []
    end

    def self.is_any_package_installed
      @@is_any_package_installed ||= false
    end

    def self.install
      # Install packages.
      packages = CommandLine.packages.empty? ? ConfigManager.package_options.keys : CommandLine.packages.uniq
      packages.each do |package_name|
        package = Package.instance package_name
        if package.has_label? :installed_with_source and
           not CommandLine.packages.include? package_name
          # :installed_with_source packages should only be specified in command line.
          next
        end
        # Binary is preferred.
        if ( package.has_binary? and not package.use_binary? and not CommandLine.has_option? '-use_binary') or package.use_binary?
          package = Package.instance package_name, 'use_binary' => true
        end
        # Let user to choose which compiler sets to use if no relevant option is set.
        if package.compiler_set_indices.empty? and not package.use_binary?
          if ConfigManager.defaults.has_key? 'compiler_set_index'
            # Use the default compiler set if specified.
            package.compiler_set_indices << ConfigManager.defaults['compiler_set_index']
          else
            # Ask user to choose the compiler sets.
            tmp = CompilerManager.compiler_sets.map { |x| x.command_hash }
            tmp << 'all'
            CLI.ask 'Which compiler sets do you want to use?', tmp
            ans = CLI.get_answer tmp
            for i in 0..CompilerManager.compiler_sets.size-1
              if ans.include? i or ans.include? CompilerManager.compiler_sets.size
                package.compiler_set_indices << i
              end
            end
          end
        end
        if not package.use_binary? and not CommandLine.has_option? '-compiler_set_indices' and
           not package.compiler_set_indices.include? ConfigManager.defaults['compiler_set_index'] and
           not package.has_label? :compiler_insensitive
          package.compiler_set_indices << ConfigManager.defaults['compiler_set_index']
        end
        package.compiler_set_indices.sort!
        # Check if the package is still under construction.
        if package.has_label? :under_construction
          msg = "Sorry, #{CLI.red package.class} is still under construction"
          why = (package.labels.select { |l| l =~ /under_construction/ }).first.gsub(/under_construction(:)?\s*/, '')
          if why != ''
            msg << " because:\n#{CLI.yellow '==>'} #{why}"
          else
            msg << "!"
          end
          CLI.report_warning msg
          next
        end
        if CommandLine.has_option? '-only_post'
          package.post_install
        else
          install_package package
        end
        # Record the installed package into config file.
        ConfigManager.package_options[package_name] = package.options
      end
      # Update config file.
      ConfigManager.write
      # Invoke switch subcommand.
      Commands.switch if is_any_package_installed
    end

    def self.is_package_installed? package, options = []
      options = [options] if not options.class == Array
      bashrc = package.bashrc
      if File.exist? bashrc
        match = File.open("#{bashrc}", 'r').read.match(/#{package.sha1}( (\d+)?)?$/)
        if match and match[2] == package.revision
          if package.check_consistency
            if not options.include? :depend
              msg = "Package #{CLI.green package.class} has been installed"
              if not package.use_binary? and not package.has_label? :compiler_insensitive
                msg << " by using compiler set #{CLI.green CompilerManager.active_compiler_set_index}"
              end
              CLI.report_notice msg+'.' if not options.include? :silent
            end
            return true
          end
        end
      elsif package.respond_to? :installed? and package.installed?
        return true
      end
      @@is_any_package_installed = true
      return false
    end

    def self.append_bashrc package, is_depend = false
      if package.has_label? :compiler_insensitive and is_depend
        # NOTE: Some :compiler_insensitive package may use other compiler set to build, and it is normally just binary,
        #       so we skip its dependent packages to avoid problems.
        PACKMAN.append_shell_source package.bashrc if not package.should_be_skipped?
        return
      end
      package.dependencies.each do |depend|
        depend_package = Package.instance depend
        append_bashrc depend_package, true
        PACKMAN.append_shell_source depend_package.bashrc if not depend_package.should_be_skipped?
      end
    end

    def self.install_package package, options = []
      options = [options] if not options.class == Array
      # Check if the package should be skipped.
      if package.should_be_skipped?
        if not package.methods.include? :installed?
          CLI.report_error "Package #{CLI.red package.class} does not have #{CLI.blue 'installed?'} method!"
        end
        if not package.installed?
          if not package.methods.include? :install
            CLI.report_error "Package #{CLI.red package.class} "+
              "should be provided by system!\n#{CLI.blue '==>'} "+
              "The possible installation method is:\n#{package.install_method}"
          end
        else
          return
        end
      end
      # Check if the package has been installed.
      if installed_packages.include? package.class
        return
      else
        installed_packages << package.class
      end
      # Check dependencies.
      package.dependencies.each do |depend|
        depend_package = Package.instance depend
        # Propagate compiler set indices.
        depend_package.update_option 'compiler_set_indices', package.compiler_set_indices
        install_package depend_package, :depend
        # TODO: Clean this.
        # When there is any dependency use MPI, we should use MPI for the package.
        if depend_package.has_option? 'use_mpi' and depend_package.use_mpi?
          PACKMAN.use_mpi depend_package.mpi
        end
      end
      # Check if the package is a master.
      if package.has_label? :master_package and not options.include? :depend and not package.respond_to? :install
        CLI.report_notice "Package master #{CLI.green package.class} has been installed."
        return
      end
      # Check if the package has been downloaded or not. If not, download it when
      # the OS is connected with internet.
      begin
        PACKMAN.download_package package
      rescue => e
        if not NetworkManager.is_connect_internet?
          CLI.report_error "#{CLI.red package.filename} has not been downloaded!\n"+
            "#{CLI.red '==>'} #{e}"
        end
      end
      # Install package.
      if package.compiler_set_indices.empty?
        # Install precompiled package.
        prefix = PACKMAN.prefix package, :compiler_insensitive
        # Check if the package has already installed.
        return if is_package_installed? package, options and not CommandLine.has_option? '-force'
        # Use precompiled binary file.
        CLI.report_notice "Use precompiled binary files for #{CLI.green package.class}."
        PACKMAN.mkdir prefix, :force
        PACKMAN.cd prefix
        PACKMAN.decompress "#{ConfigManager.package_root}/#{package.filename}"
        PACKMAN.cd_back
        # Write bashrc file for the package.
        Package.bashrc package, :compiler_insensitive
        package.post_install
      elsif package.has_label? :installed_with_source
        if package.compiler_set_indices.size != 1
          CLI.report_error "Currently, only one compiler set is allowed to build packages that are installed with source."
        end
        CompilerManager.activate_compiler_set package.compiler_set_indices.first
        if not package.target_dir
          CLI.report_error "Option #{CLI.red '-target_dir=...'} is needed!"
        end
        package.decompress_to package.target_dir
        PACKMAN.work_in package.target_dir do
          Package.apply_patch package
          msg = "Build package #{CLI.green package.class} with compiler set"
          msg << " #{CLI.green CompilerManager.active_compiler_set_index}"
          if package.has_option? 'use_mpi' and package.use_mpi?
            mpi = package.mpi == true ? ConfigManager.defaults['mpi'] : package.mpi
            if PACKMAN.compiler_has_mpi_wrapper? 'c'
              mpi = nil
              msg << " and user specified MPI library"
            else
              msg << " and #{CLI.red mpi.capitalize} library"
            end
            PACKMAN.use_mpi mpi
          end
          CLI.report_notice msg+'.'
          package.install
        end
        Package.bashrc package
        package.post_install
      else
        # Build package for each compiler set.
        build_upper_dir = "#{ConfigManager.package_root}/#{package.class}"
        package.compiler_set_indices.each do |index|
          CompilerManager.activate_compiler_set index
          # Check if the package has already installed.
          next if is_package_installed? package, options and not CommandLine.has_option? '-force'
          # Append bashrc file.
          append_bashrc package
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
          msg = "Install package #{CLI.green package.class} with compiler set"
          msg << " #{CLI.green CompilerManager.active_compiler_set_index}"
          if package.has_option? 'use_mpi' and package.use_mpi?
            if package.option_type('use_mpi') == :package_name
              msg << " and #{CLI.red package.mpi.capitalize} library"
              # Set the MPI compiler wrappers.
              PACKMAN.use_mpi package.mpi
            else
              PACKMAN.use_mpi
            end
          end
          CLI.report_notice msg+'.'
          package.install
          PACKMAN.cd_back
          FileUtils.rm_rf build_dir
          # Write bashrc file for the package.
          Package.bashrc package if not package.has_label? :not_set_bashrc
          package.post_install
          # Clean build files.
          FileUtils.rm_rf build_upper_dir if Dir.exist? build_upper_dir
        end
      end
      # Clean shell environment.
      PACKMAN.clear_shell_source if not options.include? :depend
      PACKMAN.clear_env if not options.include? :depend
    end
  end
end
