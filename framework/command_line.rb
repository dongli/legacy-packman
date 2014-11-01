module PACKMAN
  class CommandLine
    PermittedSubcommands = {
      :config => 'Edit the config file in the default location.',
      :collect => 'Collect packages from internet.',
      :install => 'Install packages and their dependencies.',
      :remove => 'Remove packages.',
      :switch => 'Switch different compiler set (new bashrc will be generated).',
      :mirror => 'Control FTP mirror service.',
      :update => 'Update PACKMAN.',
      :help => 'Print help message.',
      :report => 'Report version of PACKMAN an other information.',
      :start => 'Start a package if it provides a start method.',
      :stop => 'Stop a package if it provides a stop method.',
      :status => 'Check the status of a package if it provides a status method.'
    }.freeze
    PermittedCommonOptions = {
      '-debug' => 'Print debug information.'
    }.freeze
    PermittedOptions = {
      :config => {},
      :collect => {
        '-all' => 'Collect all packages.'
      },
      :install => {
        '-verbose' => 'Show verbose information.'
      },
      :remove => {
        '-all' => 'Remove all versions and compiler sets.',
        '-purge' => 'Also remove unneeded dependencies.'
      },
      :switch => {
        '-compiler_set_index' => 'Choose which compiler set will be used.'
      },
      :mirror => {
        '-init' => 'Initialize FTP mirror service.',
        '-start' => 'Start FTP mirror service.',
        '-stop' => 'Stop FTP mirror service.',
        '-status' => 'Check if FTP mirror service is on or off.',
        '-sync' => 'Synchronize the packages.'
      },
      :update => {},
      :help => {},
      :report => {
        '-package_root' => 'Print the download root of all packages.',
        '-install_root' => 'Print the installation root of all packages.'
      },
      :start => {},
      :stop => {},
      :status => {}
    }.freeze

    def self.init
      CLI.report_error "PACKMAN expects a subcommand!" if ARGV.empty?
      @@subcommand = nil
      @@config_file = nil
      @@packages = []
      @@options = {}
      ARGV.each do |arg|
        if PermittedSubcommands.keys.include? arg.to_sym
          @@subcommand = arg.to_sym
          next
        end
        if not @@subcommand
          CLI.report_error "PACKMAN expects a subcommand!"
        end
        if File.file? arg
          @@config_file = arg
          next
        end
        if Package.all_package_names.include? arg
          @@packages << arg.capitalize.to_sym
          next
        end
        key = arg.gsub(/=.*/, '')
        value = arg.match(/=(.*)/)
        if value
          @@options[key] = value[1]
        else
          @@options[key] = nil
        end
      end
      if [:config, :collect, :install, :remove, :switch, :mirror,
          :start,   :stop, :status, :report].include? @@subcommand and
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
      @@process_exclusive = false
      if [:install, :remove, :mirror].include? @@subcommand
        @@process_exclusive = true
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

    def self.options
      @@options ||= {}
    end

    def self.is_option_defined_in? package, option_name
      package.dependencies.each do |depend|
        depend_package = Package.instance depend
        return true if is_option_defined_in? depend_package, option_name
      end
      package.options.has_key? option_name.gsub(/^-/, '')
    end

    def self.check_options
      # Check options.
      @@options.each_key do |key|
        next if PermittedOptions[@@subcommand].has_key? key or PermittedCommonOptions.has_key? key
        is_found = false
        @@packages.each do |package_name|
          package = Package.instance package_name
          if is_option_defined_in? package, key
            is_found = true
            break
          end
        end
        ConfigManager.package_options.each_key do |package_name|
          package = Package.instance package_name
          if is_option_defined_in? package, key
            is_found = true
            break
          end
        end
        next if is_found or PackageSpec::CommonOptions.has_key? key.gsub(/^-/, '')
        if not is_found
          CLI.report_error "Invalid command option #{CLI.red key}!\n"+
            "The available options are:\n#{print_options(@@subcommand, 2).chomp}"
        end
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

    def self.propagate_options_to package
      return if not options or options.empty?
      for i in 0..package.options.size-1
        key = package.options.keys[i]
        next if not options.has_key? "-#{key}"
        value = options["-#{key}"]
        package.update_option key, value
      end
    end
  end
end
