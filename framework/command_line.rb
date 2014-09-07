module PACKMAN
  class CommandLine
    @@subcommand = nil
    @@config_file = nil
    @@options = []

    @@permitted_subcommands = {
      'collect' => 'Collect packages from internet.',
      'install' => 'Install packages and their dependencies.',
      'update'  => 'Update PACKMAN.',
      'help'    => 'Print help message.'
    }
    @@permitted_options = {
      'collect' => {},
      'install' => {
        '-v' => 'Show verbose information.'
      },
      'update'  => {},
      'help'    => {}
    }
    
    def self.init
      if ARGV.empty?
        PACKMAN.report_error "PACKMAN expects a subcommand!"
      end
      ARGV.each do |arg|
        if @@permitted_subcommands.keys.include? arg
          @@subcommand = arg
          next
        end
        if not @@subcommand
          PACKMAN.report_error "PACKMAN expects a subcommand!"
        end
        if File.file? arg
          @@config_file = arg
          next
        end
        if @@permitted_options[@@subcommand].has_key? arg
          @@options << arg
        else
          PACKMAN.report_error "Invalid command option "+
            "#{PACKMAN::Tty.red}#{arg}#{PACKMAN::Tty.reset}!\n"+
            "The available options are:\n#{print_options(@@subcommand, 2).chomp}"
        end
      end
      if ['collect', 'install'].include? @@subcommand and not @@config_file
        PACKMAN::ConfigManager.template('./packman.config')
        PACKMAN.report_warning "Lack configure file, PACKMAN generate one for you! "+
        "Edit #{PACKMAN::Tty.red}packman.config#{PACKMAN::Tty.reset} and come back."
        exit
      end
    end

    def self.subcommand
      @@subcommand
    end

    def self.config_file
      @@config_file
    end

    def self.has_option?(option)
      @@options.include? option
    end

    def self.print_options(subcommand, indent = 0)
      res = ''
      @@permitted_options[subcommand].each do |option, meaning|
        for i in 0..indent-1
          res << ' '
        end
        res << "#{PACKMAN::Tty.bold(option)}\t#{meaning}\n"
      end
      return res
    end

    def self.print_usage(indent = 2)
      res = "Usage: packman <subcommand> [options] <config file>\n\n"
      @@permitted_subcommands.each do |subcommand, meaning|
        for i in 0..indent-1
          res << ' '
        end
        res << "#{PACKMAN::Tty.bold(subcommand)}\t#{meaning}\n\n"
        res << print_options(subcommand, indent+2)
        res.chomp!
        res << "\n\n"
      end
      print res
    end
  end
end
