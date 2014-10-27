module PACKMAN
  class Commands
    def self.install
      @@is_any_package_installed = false
      # Install packages.
      packages = CommandLine.packages.empty? ? ConfigManager.package_options.keys : CommandLine.packages
      packages.each do |package_name|
        package = Package.instance package_name
        # Check possible package options from config file.
        ConfigManager.propagate_options_to package
        # Check possible package options from command line.
        CommandLine.propagate_options_to package
        # Binary is preferred.
        if package.has_binary? and not package.use_binary?
          package.options['use_binary'] = true
        end
        # Let user to choose which compiler sets to use if no relevant option is set.
        if package.compiler_set_indices.empty? and not package.use_binary?
          if ConfigManager.defaults.has_key? 'compiler_set_index'
            # Use the default compiler set if specified.
            package.compiler_set_indices << ConfigManager.defaults['compiler_set_index']
          else
            # Ask user to choose the compiler sets.
            tmp = ConfigManager.compiler_sets.clone
            tmp << 'all'
            CLI.ask 'Which compiler sets do you want to use?', tmp
            ans = CLI.get_answer tmp
            for i in 0..ConfigManager.compiler_sets.size-1
              if ans.include? i or ans.include? ConfigManager.compiler_sets.size
                package.compiler_set_indices << i
              end
            end
          end
        end
        # Reload package definition file since user input may change its dependencies.
        options = package.options.clone
        PackageLoader.load_package package_name, options
        # Reinstance package to make changes effective.
        package = Package.instance package_name, options
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
        CLI.report_error "#{package.class}" if not package.use_binary?
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
                msg << " by using compiler set #{CLI.green ConfigManager.compiler_sets.index(Package.compiler_set)}"
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
      compiler_sets = ConfigManager.compiler_sets.select.with_index { |x, i| package.compiler_set_indices.include? i }
      # NOTE: To avoid GCC build itself!
      return if package.has_label? 'compiler_insensitive' and is_package_installed? package, options
      # Check dependencies.
      package.dependencies.each do |depend|
        # TODO: How to handle dependency install_spec?
        depend_package = Package.instance depend
        install_package depend_package, :depend
        # TODO: Clean this.
        # When there is any dependency use MPI, we should use MPI for the package.
        # if depend_package.conflict_reasons.include? 'mpi'
        #   PACKMAN.use_mpi depend.to_s.downcase
        # end
        RunManager.append_bashrc_path("#{PACKMAN.prefix(depend_package)}/bashrc") if not depend_package.skip?
      end
      # Check if the package is a master.
      if package.has_label? 'package_master'
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
      if compiler_sets.empty?
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
      else
        # Build package for each compiler set.
        build_upper_dir = "#{ConfigManager.package_root}/#{package.class}"
        compiler_sets.each do |compiler_set|
          Package.compiler_set = compiler_set
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
          msg << " #{CLI.green ConfigManager.compiler_sets.index(compiler_set)}"
          if package.has_option? 'use_mpi' and package.use_mpi?
            msg << " and #{CLI.red package.mpi.capitalize} library"
            # Set the MPI compiler wrappers.
            PACKMAN.use_mpi package.mpi
          end
          CLI.report_notice msg+"."
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
    end
  end
end
