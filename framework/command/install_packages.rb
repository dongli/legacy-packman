module PACKMAN
  def self.install_packages
    CompilerManager.expand_packman_compiler_sets
    # Report compilers and their flags.
    for i in 0..ConfigManager.compiler_sets.size-1
      CLI.report_notice "Compiler set #{CLI.green i}:"
      ConfigManager.compiler_sets[i].each do |language, compiler|
        next if language == 'installed_by_packman'
        print "#{CLI.blue '==>'} #{language}: #{compiler} #{CompilerManager.default_flags language, compiler}\n"
      end
    end
    # Install packages.
    if CommandLine.packages.empty?
      install_packages_defined_in_config_file
    else
      install_packages_defined_in_command_line
    end
  end

  def self.install_packages_defined_in_config_file
    ConfigManager.packages.each do |package_name, install_spec|
      if not Package.defined? package_name
        CLI.report_warning "Unknown package #{CLI.red package_name}!"
        next
      end
      package = Package.instance package_name, install_spec
      if package.has_binary?
        # Binary is preferred.
        install_spec['use_binary'] = true
        # Reinstance package to make binary choice effective.
        package = Package.instance package_name, install_spec
      end
      # Check if the compiler_set option is set when necessary.
      if not install_spec['use_binary'] and
        not package.has_label? 'compiler_insensitive' and
        not install_spec.has_key? 'compiler_set'
        CLI.report_error "Compiler set indices are not specified for package \"#{package_name}\"!"
      end
      if not install_spec['use_binary']
        # When a package is labeled as 'compiler_insensitive', and no 'compiler_set' is specified, use the first one.
        if package.has_label? 'compiler_insensitive' and not install_spec.has_key? 'compiler_set'
          install_spec['compiler_set'] = [0]
        end
        install_spec.each do |key, value|
          case key
          when 'compiler_set'
            install_spec['compiler_set'].each do |index|
              if index.class != Fixnum
                CLI.report_error "Bad compiler sets format \"#{value}\" in package \"#{package_name}\"!"
              elsif index < 0 or index >= ConfigManager.compiler_sets.size
                CLI.report_error "Compiler set index is out of range in package \"#{package_name}\"!"
              end
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
      # Check which compiler sets are to use.
      compiler_sets = []
      if not install_spec['use_binary']
        for i in 0..ConfigManager.compiler_sets.size-1
          if install_spec['compiler_set'].include?(i)
            compiler_sets.push ConfigManager.compiler_sets[i]
          end
        end
      end
      install_package compiler_sets, package
    end
  end

  def self.install_packages_defined_in_command_line
    CommandLine.packages.each do |package_name|
      package_config = {} # For recording user inputs.
      package = Package.instance package_name
      install_spec = {}
      compiler_sets = []
      # Check possible install_spec from config file.
      if ConfigManager.packages.keys.include? package_name
        install_spec.merge! ConfigManager.packages[package_name]
        package_config.merge! ConfigManager.packages[package_name]
      end
      # Check package labels.
      package.labels.each do |label|
        case label
        when 'compiler_insensitive'
          if package.has_binary?
            # Binary is preferred.
            install_spec['use_binary'] = true
            package_config['use_binary'] = true
          else
            # The first compiler set is preferred.
            compiler_sets << ConfigManager.compiler_sets[ConfigManager.defaults['compiler_set']]
            package_config['compiler_set'] = [ConfigManager.defaults['compiler_set']]
          end
        end
      end
      # Check package options.
      package.options.each do |key, value|
        case key
        when 'use_mpi'
          if not CommandLine.has_option? '-no-mpi'
            if ConfigManager.defaults.has_key? 'mpi' and not CommandLine.has_option? '-ask'
              package.options[key] = ConfigManager.defaults['mpi']
            else
              tmp = ['no', 'mpich', 'openmpi']
              CLI.ask "#{CLI.red package.class} can be built with MPI, do you want this?", tmp
              ans = CLI.get_answer tmp, :only_one
              package.options[key] = ans == 0 ? nil : tmp[ans]
            end
            package_config['use_mpi'] = package.options[key]
          end
        end
      end
      # Let user to choose which compiler sets to use.
      if compiler_sets.empty?
        if not install_spec['use_binary']
          package_config['compiler_set'] = []
          if ConfigManager.defaults.has_key? 'compiler_set' and not CommandLine.has_option? '-ask'
            package_config['compiler_set'] << 0
            compiler_sets << ConfigManager.compiler_sets[ConfigManager.defaults['compiler_set']]
          else
            tmp = ConfigManager.compiler_sets.clone
            tmp << 'all'
            CLI.ask 'Which compiler sets do you want to use?', tmp
            ans = CLI.get_answer tmp
            for i in 0..ConfigManager.compiler_sets.size-1
              if ans.include? i or ans.include? ConfigManager.compiler_sets.size
                package_config['compiler_set'] << i
                compiler_sets << ConfigManager.compiler_sets[i]
              end
            end
          end
        end
      end
      # Reload package definition file since user input may change its dependencies.
      PackageLoader.load_package package_name, install_spec
      # Reinstance package to make changes effective.
      package = Package.instance package_name, install_spec
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
      install_package compiler_sets, package
      # Record the installed package into config file.
      ConfigManager.packages[package_name] = package_config
    end
    # Update config file.
    ConfigManager.write
  end

  def self.install_package compiler_sets, package, options = []
    options = [options] if not options.class == Array
    # Check dependencies.
    package.dependencies.each do |depend|
      # TODO: How to handle dependency install_spec?
      depend_package = Package.instance depend
      install_package compiler_sets, depend_package, :depend
      RunManager.append_bashrc_path("#{Package.prefix(depend_package)}/bashrc") if not depend_package.skip?
    end
    # Check if the package should be skipped.
    if package.skip?
      if not package.skip_distros.include? :all and not package.installed?
        CLI.report_error "Package #{PACKMAN::CLI.red package.class} "+
          "should be provided by system!\n#{PACKMAN::CLI.blue '==>'} "+
          "The possible installation method is:\n#{package.install_method}"
      end
      return
    end
    # Check if the package has been downloaded or not. If not, download it when
    # the OS is connected with internet.
    begin
      PACKMAN.download_package package
    rescue => e
      if not OS.connect_internet?
        CLI.report_error "#{CLI.red package.filename} has not been downloaded!\n"+
          "#{CLI.red '==>'} #{e}"
      end
    end
    # Install package.
    if compiler_sets.empty?
      # Install precompiled package.
      prefix = Package.prefix package, :compiler_insensitive
      # Check if the package has alreadly installed.
      bashrc = "#{prefix}/bashrc"
      if File.exist?(bashrc)
        first_line = File.new(bashrc, 'r').readline
        if first_line =~ /#{package.sha1}/
          CLI.report_notice "Package #{PACKMAN::CLI.green package.class} has been installed." if not options.include? :depend
          return
        end
      end
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
        # Set the MPI compiler wrappers.
        use_mpi package.options['use_mpi'] if package.options['use_mpi']
        # Check if the package has alreadly installed.
        bashrc = "#{Package.prefix(package)}/bashrc"
        if File.exist? bashrc
          first_line = File.new(bashrc, 'r').readline
          if first_line =~ /#{package.sha1}/
            if (package.respond_to? :check_consistency and package.check_consistency) or
              not package.respond_to? :check_consistency
              CLI.report_notice "Package #{PACKMAN::CLI.green package.class} has been installed." if not options.include? :depend
              next
            end
          end
        end
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
        msg << " #{PACKMAN::CLI.green ConfigManager.compiler_sets.index(compiler_set)}"
        msg << " and #{PACKMAN::CLI.red package.options['use_mpi'].capitalize} library" if package.options['use_mpi']
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
