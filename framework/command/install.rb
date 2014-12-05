module PACKMAN
  class Commands
    def self.install
      @@is_any_package_installed = false
      # Install packages.
      packages = ( ConfigManager.package_options.keys | CommandLine.packages ).uniq
      packages.each do |package_name|
        package = Package.instance package_name
        if package.has_label? 'install_with_source' and
           not CommandLine.packages.include? package_name
          # 'install_with_source' packages should only be specified in command line.
          next
        end
        # Binary is preferred (default value is nil).
        if ( package.has_binary? and package.use_binary? == nil ) or package.use_binary?
          package = Package.instance package_name, 'use_binary' => true
        end
        # Let user to choose which compiler sets to use if no relevant option is set.
        if package.compiler_set_indices.empty? and not package.use_binary?
          if ConfigManager.defaults.has_key? 'compiler_set_index'
            # Use the default compiler set if specified.
            package.compiler_set_indices << ConfigManager.defaults['compiler_set_index']
          else
            # Ask user to choose the compiler sets.
            tmp = CompilerManager.compiler_sets.clone
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
        # Check if the package is still under construction.
        if package.has_label? 'under_construction'
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
        install_package package
        # Record the installed package into config file.
        ConfigManager.package_options[package_name] = package.options
      end
      # Update config file.
      ConfigManager.write
      # Invoke switch subcommand.
      Commands.switch if @@is_any_package_installed
    end

    def self.is_package_installed? package, options = []
      if options.include? :binary
        CLI.report_error "#{CLI.red package.class} does not have precompiled binary!" if not package.use_binary?
        bashrc = "#{PACKMAN.prefix package, :compiler_insensitive}/bashrc"
      else
        bashrc = "#{PACKMAN.prefix package}/bashrc"
      end
      if File.exist? bashrc
        content = File.open("#{bashrc}", 'r').readlines
        if not content.grep(/#{package.sha1}/).empty?
          if (package.respond_to? :check_consistency and package.check_consistency) or
            not package.respond_to? :check_consistency
            if not options.include? :depend
              msg = "Package #{CLI.green package.class} has been installed"
              if not package.use_binary? and not package.has_label? 'compiler_insensitive'
                msg << " by using compiler set #{CLI.green CompilerManager.active_compiler_set_index}"
              end
              CLI.report_notice msg+'.'
            end
            return true
          end
        end
      end
      @@is_any_package_installed = true
      return false
    end

    def self.install_package package, options = []
      options = [options] if not options.class == Array
      # Set compiler sets.
      # NOTE: To avoid GCC build itself!
      return if package.has_label? 'compiler_insensitive' and is_package_installed? package, options
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
        RunManager.append_bashrc_path("#{PACKMAN.prefix(depend_package)}/bashrc") if not depend_package.skip?
      end
      # Check if the package is a master.
      if package.has_label? 'master_package' and not options.include? :depend
        CLI.report_notice "Package master #{CLI.green package.class} has been installed."
        return
      end
      # Check if the package should be skipped.
      if package.skip?
        if not package.skip_distros.include? :all and not package.installed?
          CLI.report_error "Package #{CLI.red package.class} "+
            "should be provided by system!\n#{CLI.blue '==>'} "+
            "The possible installation method is:\n#{package.install_method}"
        end
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
        return if is_package_installed? package, options << :binary
        # Use precompiled binary file.
        CLI.report_notice "Use precompiled binary files for #{CLI.green package.class}."
        PACKMAN.mkdir prefix, :force
        PACKMAN.cd prefix
        PACKMAN.decompress "#{ConfigManager.package_root}/#{package.filename}"
        PACKMAN.cd_back
        # Write bashrc file for the package.
        Package.bashrc package, :compiler_insensitive
        package.postfix
      elsif package.has_label? 'install_with_source'
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
            msg << " and #{CLI.red package.mpi.capitalize} library"
            PACKMAN.use_mpi package.mpi
          end
          CLI.report_notice msg+'.'
          package.install
        end
        Package.bashrc package
        package.postfix
        CompilerManager.clean_customized_flags
      else
        # Build package for each compiler set.
        build_upper_dir = "#{ConfigManager.package_root}/#{package.class}"
        package.compiler_set_indices.each do |index|
          CompilerManager.activate_compiler_set index
          # Check if the package has already installed.
          next if is_package_installed? package, options
          # Decompress package file.
          if package.respond_to? :filename
            package.decompress_to ConfigManager.package_root
          elsif package.respond_to? :dirname
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
            msg << " and #{CLI.red package.mpi.capitalize} library"
            # Set the MPI compiler wrappers.
            PACKMAN.use_mpi package.mpi
          end
          CLI.report_notice msg+'.'
          package.install
          PACKMAN.cd_back
          FileUtils.rm_rf build_dir
          # Write bashrc file for the package.
          Package.bashrc package
          package.postfix
          # Clean the customized flags if there is any.
          CompilerManager.clean_customized_flags
        end
        # Clean build files.
        FileUtils.rm_rf build_upper_dir if Dir.exist? build_upper_dir
        # Clean the bashrc pathes.
        RunManager.clean_bashrc_path if not options.include? :depend
      end
      if not options.include? :depend
        RunManager.clean_env
      end
    end
  end
end
