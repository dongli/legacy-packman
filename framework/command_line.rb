module PACKMAN
  class CommandLine
    PermittedSubcommands = {
      :collect => 'Collect packages from internet.',
      :config => 'Edit the config file in the default location.',
      :edit => 'Open the class file for the given package',
      :fix => 'Fix the potential legacy errors.',
      :help => 'Print help message.',
      :install => 'Install packages and their dependencies.',
      :link => 'Link installed package files into one directory.',
      :mirror => 'Control FTP mirror service.',
      :relocate => 'Relocate installed packages into a new directory.',
      :remove => 'Remove packages.',
      :report => 'Report version of PACKMAN an other information.',
      :start => 'Start a package if it provides a start method.',
      :status => 'Check the status of a package if it provides a status method.',
      :stop => 'Stop a package if it provides a stop method.',
      :store => 'Pack a package and store it online.',
      :switch => 'Switch different compiler set (new bashrc will be generated).',
      :unlink => 'Unlink installed package files from central directory.',
      :update => 'Update PACKMAN.',
      :upgrade => 'Upgrade packages.',
    }.freeze
    PermittedCommonOptions = {
      '-debug' => 'Print debug information.',
      '-config' => 'Specify configure file.',
      '-verbose' => 'Show verbose information.'
    }.freeze
    PermittedOptions = {
      :collect => {
        '-all' => 'Collect all packages.'
      },
      :config => {
        '-silent' => 'Do not print message and enter editor.'
      },
      :edit => {},
      :fix => {},
      :help => {},
      :install => {
        '-force' => 'Force to run install procedures no matter packages are installed or not.',
        '-only_post' => 'Only run post-install procedures.'
      },
      :link => {},
      :mirror => {
        '-init' => 'Initialize FTP mirror service.',
        '-start' => 'Start FTP mirror service.',
        '-stop' => 'Stop FTP mirror service.',
        '-status' => 'Check if FTP mirror service is on or off.',
        '-sync' => 'Synchronize the packages.',
        '-scan' => 'Scan for FTP mirrors.'
      },
      :relocate => {
        '-new_root' => 'New root directory for the installed packages.'
      },
      :remove => {
        '-all' => 'Remove all versions and compiler sets.',
        '-purge' => 'Also remove unneeded dependencies.'
      },
      :report => {
        '-compiler_sets' => 'Print the compiler sets (e.g., compiler commands).',
        '-package_root' => 'Print the download root of all packages.',
        '-install_root' => 'Print the installation root of all packages.',
        '-installed_packages' => 'Print the installed packages.',
        '-package_options' => 'Print the available options of the package.'
      },
      :start => {},
      :status => {},
      :stop => {},
      :store => {},
      :switch => {
        '-compiler_set_index' => 'Choose which compiler set will be used.',
        '-output' => 'Set the output BASH configure file path (Default is <package_root>/packman.bashrc).'
      },
      :unlink => {},
      :update => {},
      :upgrade => {},
    }.freeze

    def self.init
      CLI.report_error "PACKMAN expects a subcommand!" if ARGV.empty?
      @@subcommand = nil
      @@config_file = nil
      @@packages = []
      @@package_method = nil
      @@options = {}
      ARGV.each do |arg|
        if PermittedSubcommands.keys.include? arg.to_sym
          @@subcommand = arg.to_sym
          next
        end
        if Package.all_package_names.include? arg
          @@packages << arg.to_sym
          next
        end
        if not @@subcommand
          CLI.report_error "PACKMAN expects a subcommand!" if @@packages.empty?
          package = Package.instance @@packages.first
          if package.public_methods.include? arg.to_sym
            @@package_method = arg.to_sym
            next
          end
        end
        key = arg.gsub(/=.*/, '')
        value = arg.match(/=(.*)/)
        if value
          @@options[key] = value[1]
        else
          @@options[key] = nil
        end
      end
      @@config_file = options['-config'] if has_option? '-config'
      if [:config, :collect, :start, :fix, :upgrade, :update,  :stop, :status,  :report,
          :install, :switch, :remove, :mirror, :link, :unlink, :relocate, :store, nil].include? @@subcommand and
         not @@config_file
        # Check if there is a configuration file in PACKMAN_ROOT.
        @@config_file = "#{ENV['PACKMAN_ROOT']}/packman.config"
        if not File.exist? @@config_file
          ConfigManager.template("#{ENV['PACKMAN_ROOT']}/packman.config")
          if not @@subcommand == :config
            CLI.report_warning "Lack configure file, PACKMAN generate one for you! Edit "+
              "#{CLI.red @@config_file} and come back."
            exit
          end
        end
      end
      @@process_exclusive = true
      if [ :edit, :switch, :report, :status, :store ].include? @@subcommand
        @@process_exclusive = false
      end
    end

    def self.run
      if @@subcommand
        if not Commands.respond_to? @@subcommand
          PACKMAN.report_error "Unknown subcommand "+
            "#{PACKMAN::CommandLine.subcommand}!"
        end
        PACKMAN::Commands.send PACKMAN::CommandLine.subcommand
      else
        PACKMAN::Commands.delegate
      end
    end

    def self.subcommand
      @@subcommand ||= nil
    end

    def self.process_exclusive?
      if defined? @@process_exclusive
        return @@process_exclusive
      else
        CLI.report_error "Unexpected branch!"
      end
    end

    def self.config_file
      @@config_file ||= nil
    end

    def self.packages
      @@packages ||= []
    end

    def self.package_method
      @@package_method
    end

    def self.options
      @@options ||= {}
    end

    def self.is_option_defined_in? package, option_name
      package.dependencies.each do |depend|
        depend_package = Package.instance depend
        return true if is_option_defined_in? depend_package, option_name
      end
      package.options.has_key? option_name.gsub(/^[-+]/, '').to_sym
    end

    def self.check_options
      # Check options.
      @@options.each_key do |key|
        next if @@subcommand and PermittedOptions[@@subcommand].has_key? key
        next if PermittedCommonOptions.has_key? key
        next if PackageSpec::CommonOptions.has_key? key.gsub(/^(-|\+)/, '').to_sym
        is_found = false
        @@packages.each do |package_name|
          package = Package.instance package_name
          if is_option_defined_in? package, key
            is_found = true
            break
          end
        end
        next if is_found
        CLI.report_error "Invalid command option #{CLI.red key}!\n"+
          "The available options are:\n#{print_options(@@subcommand, 2).chomp}"
      end
    end

    def self.has_option? option
      options.has_key? option
    end

    def self.print_options subcommand, indent = 0
      res = ''
      PermittedOptions[subcommand].each do |option, meaning|
        for i in 0..indent-1
          res << ' '
        end
        res << "#{CLI.bold option}\t#{meaning}\n"
      end
      return res
    end

    def self.print_usage indent = 2
      res = "Usage: packman <subcommand> [options] <config file>\n\n"
      PermittedSubcommands.each do |subcommand, meaning|
        for i in 0..indent-1
          res << ' '
        end
        res << "#{CLI.bold subcommand}\t#{meaning}\n\n"
        res << print_options(subcommand, indent+2)
        res.chomp!
        res << "\n\n"
      end
      print res
    end

    def self.is_option_limited? option_name, package
      # Only packages specified in command line should adopt the option.
      package_name = package.master_package ? package.master_package : package.name
      CommandLine.options.has_key? "+#{option_name}" and not CommandLine.packages.include? package_name.to_sym
    end

    def self.propagate_options_to package
      return if not options or options.empty?
      for i in 0..package.options.size-1
        key = package.options.keys[i]
        next if is_option_limited? key, package
        if options.has_key? "-#{key}"
          value = options["-#{key}"]
        elsif options.has_key? "+#{key}"
          value = options["+#{key}"]
        else
          next
        end
        package.update_option key, value
      end
    end
  end
end
