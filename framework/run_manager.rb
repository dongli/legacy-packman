module PACKMAN
  class RunManager
    def self.delegated_methods
      [:run, :run_no_redirect]
    end

    def self.default_command_prefix
      cmd_str = ''
      # Reset (DY)LD_LIBRARY_PATH environment variable to avoid potential problems.
      PACKMAN.filter_ld_library_path
      # Handle PACKMAN installed compiler.
      if not CompilerManager.active_compiler_set
        CompilerManager.activate_compiler_set ConfigManager.defaults['compiler_set_index']
      end
      if CompilerManager.active_compiler_set.installed_by_packman?
        compiler_prefix = PACKMAN.prefix CompilerManager.active_compiler_set.package_name
        PACKMAN.append_shell_source "#{compiler_prefix}/bashrc"
      end
      # Handle RPATH variable.
      if not PACKMAN.shell_sources.empty?
        PACKMAN.shell_sources.each do |shell_source|
          tmp = File.open(shell_source).read.match(/\w+_RPATH="(.*)"/)
          # Add RPATH options to ensure the correct libraries are linked.
          next if not tmp
          tmp[1].split(':').each do |rpath|
            PACKMAN.append_env 'LDFLAGS', PACKMAN.compiler('c').flag(:rpath).(rpath)
          end
        end
      end
      # Handle compilers.
      CompilerManager.active_compiler_set.compilers.each do |language, compiler|
        flags = compiler.default_flags[language]
        PACKMAN.append_env PACKMAN.compiler_flags_env_name(language), flags
        case language
        when 'c'
          PACKMAN.reset_env 'CC', compiler.command
        when 'c++'
          PACKMAN.reset_env 'CXX', compiler.command
        when 'fortran'
          PACKMAN.reset_env 'F77', compiler.command
          PACKMAN.reset_env 'FC', compiler.command
        end
      end
      # Handle customized environment variables.
      PACKMAN.env_keys.each do |key|
        cmd_str << "#{PACKMAN.export_env key} && "
      end
      # Handle customized bashrc.
      if not PACKMAN.shell_sources.empty?
        PACKMAN.shell_sources.each do |shell_source|
          # Note: Use '.' instead of 'source', since Ruby system seems invoke a dash not fully bash!
          cmd_str << ". #{shell_source} && "
        end
      end
      return cmd_str
    end

    def self.run cmd, *args
      cmd_str = default_command_prefix
      cmd_args = args.join(' ')
      cmd_str << " #{cmd} "
      cmd_str << "#{cmd_args} "
      if CommandLine.has_option? '-debug'
        PACKMAN.blue_arrow cmd_str
      else
        PACKMAN.blue_arrow "#{cmd} #{cmd_args}", :truncate
      end
      if not CommandLine.has_option? '-verbose'
        cmd_str << "1> #{ConfigManager.package_root}/stdout 2> #{ConfigManager.package_root}/stderr"
      end
      system cmd_str
      if not $?.success?
        info =  "PATH: #{FileUtils.pwd}\n"
        info << "Command: #{cmd_str}\n"
        info << "Return: #{$?}\n"
        if not CommandLine.has_option? '-verbose'
          info << "Standard output: #{ConfigManager.package_root}/stdout\n"
          info << "Standard error: #{ConfigManager.package_root}/stderr\n"
        end
        CLI.report_error "Failed to run the following command:\n"+info
      end
      if not CommandLine.has_option? '-verbose'
        FileUtils.rm("#{ConfigManager.package_root}/stdout")
        FileUtils.rm("#{ConfigManager.package_root}/stderr")
      end
    end

    def self.run_no_redirect cmd, *args
      cmd_str = default_command_prefix
      cmd_args = args.join(' ')
      cmd_str << " #{cmd} "
      cmd_str << "#{cmd_args} "
      if CommandLine.has_option? '-debug'
        PACKMAN.blue_arrow cmd_str
      else
        PACKMAN.blue_arrow "#{cmd} #{cmd_args}", :truncate
      end
      system cmd_str
      if not $?.success?
        info =  "PATH: #{FileUtils.pwd}\n"
        info << "Command: #{cmd_str}\n"
        info << "Return: #{$?}\n"
        CLI.report_error "Failed to run the following command:\n"+info
      end
    end
  end
end
