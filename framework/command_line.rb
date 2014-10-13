module PACKMAN
  class CommandLine
    @@subcommand = nil
    @@config_file = nil
    @@options = []
    @@packages = []

    @@permitted_subcommands = {
      :config  => 'Edit the config file in the default location.',
      :collect => 'Collect packages from internet.',
      :install => 'Install packages and their dependencies.',
      :remove  => 'Remove packages.',
      :switch  => 'Switch different compiler set (new bashrc will be generated).',
      :mirror  => 'Control FTP mirror service.',
      :update  => 'Update PACKMAN.',
      :help    => 'Print help message.',
      :report  => 'Report version of PACKMAN an other information.',
      :start   => 'Start a package if it provides a start method.',
      :stop    => 'Stop a package if it provides a stop method.',
      :status  => 'Check the status of a package if it provides a status method.'
    }
    @@permitted_common_options = {
      '-debug' => 'Print debug information.'
    }
    @@permitted_options = {
      :config  => {},
      :collect => {
        '-all'   => 'Collect all packages.'
      },
      :install => {
        '-verbose' => 'Show verbose information.',
        '-ask'     => 'Ask user when there are choices.',
        '-no-mpi'  => 'Suppress MPI dependency.'
      },
      :remove => {
        '-all'   => 'Remove all versions and compiler sets.',
        '-purge' => 'Also remove unneeded dependencies.'
      },
      :switch  => {},
      :mirror  => {
        '-init'   => 'Initialize FTP mirror service.',
        '-start'  => 'Start FTP mirror service.',
        '-stop'   => 'Stop FTP mirror service.',
        '-status' => 'Check if FTP mirror service is on or off.',
        '-sync'   => 'Synchronize the packages.'
      },
      :update  => {},
      :help    => {},
      :report  => {},
      :start   => {},
      :stop    => {},
      :status  => {}
    }

    def self.init
      if ARGV.empty?
        CLI.report_error "PACKMAN expects a subcommand!"
      end
      ARGV.each do |arg|
        if @@permitted_subcommands.keys.include? arg.to_sym
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
        if @@permitted_options[@@subcommand].has_key? arg or
          @@permitted_common_options.has_key? arg
          @@options << arg
        else
          CLI.report_error "Invalid command option #{CLI.red arg}!\n"+
            "The available options are:\n#{print_options(@@subcommand, 2).chomp}"
        end
      end
      if [:config, :collect, :install, :remove, :switch, :mirror,
          :start,   :stop, :status].include? @@subcommand and
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
    end

    def self.subcommand
      @@subcommand
    end

    def self.config_file
      @@config_file
    end

    def self.packages
      @@packages
    end

    def self.has_option? option
      @@options.include? option
    end

    def self.print_options subcommand, indent = 0
      res = ''
      @@permitted_options[subcommand].each do |option, meaning|
        for i in 0..indent-1
          res << ' '
        end
        res << "#{CLI.bold(option)}\t#{meaning}\n"
      end
      return res
    end

    def self.print_usage indent = 2
      res = "Usage: packman <subcommand> [options] <config file>\n\n"
      @@permitted_subcommands.each do |subcommand, meaning|
        for i in 0..indent-1
          res << ' '
        end
        res << "#{CLI.bold(subcommand.to_s)}\t#{meaning}\n\n"
        res << print_options(subcommand, indent+2)
        res.chomp!
        res << "\n\n"
      end
      print res
    end
  end
end
