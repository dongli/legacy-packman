module PACKMAN
  class RunManager
    def self.delegated_methods
      [:run]
    end

    def self.default_command_prefix
      cmd_str = ''
      PACKMAN.append_env 'CPPFLAGS', PACKMAN.cppflags
      PACKMAN.append_env 'LDFLAGS', PACKMAN.ldflags
      # Handle RPATH variable.
      rpath_flags = PACKMAN.os.generate_rpaths(PACKMAN.link_root, :wrap_flag).join(' ')
      PACKMAN.append_env 'LDFLAGS', rpath_flags
      # Handle compilers.
      CompilerManager.active_compiler_set.compilers.each do |language, compiler|
        flags = compiler.default_flags[language]
        PACKMAN.append_env PACKMAN.compiler_flags_env_name(language), flags
        case language
        when :c
          PACKMAN.reset_env 'CC', compiler.command if not PACKMAN.has_env? 'CC'
        when :cxx
          PACKMAN.reset_env 'CXX', compiler.command if not PACKMAN.has_env? 'CXX'
        when :fortran
          PACKMAN.reset_env 'F77', compiler.command if not PACKMAN.has_env? 'F77'
          PACKMAN.reset_env 'FC', compiler.command if not PACKMAN.has_env? 'FC'
        end
      end
      # Handle customized environment variables.
      PACKMAN.env_keys.each do |key|
        cmd_str << "#{PACKMAN.export_env key} && "
      end
      return cmd_str
    end

    def self.run cmd, *args
      cmd_str = default_command_prefix
      cmd_args = args.select { |a| a.class == String }.join(' ')
      run_args = args.select { |a| a.class == Symbol }
      cmd_str << " #{cmd} "
      cmd_str << "#{cmd_args} "
      if CommandLine.has_option? '-debug'
        PACKMAN.blue_arrow cmd_str
      else
        PACKMAN.blue_arrow "#{cmd} #{cmd_args}", :truncate
      end
      if not CommandLine.has_option? '-verbose' and not run_args.include? :screen_output and not run_args.include? :return_output
        cmd_str << "1> #{ConfigManager.package_root}/stdout 2> #{ConfigManager.package_root}/stderr"
      end
      if run_args.include? :return_output
        res = `#{cmd_str} 2>&1`
      else
        system cmd_str
      end
      if not $?.success? and not run_args.include? :skip_error
        info =  "PATH: #{FileUtils.pwd}\n"
        info << "Command: #{cmd_str}\n"
        info << "Return: #{$?}\n"
        if not CommandLine.has_option? '-verbose'
          info << "Standard output: #{ConfigManager.package_root}/stdout\n"
          info << "Standard error: #{ConfigManager.package_root}/stderr\n"
        end
        CLI.report_error "Failed to run the following command:\n"+info
      end
      if not CommandLine.has_option? '-verbose' and not run_args.include? :screen_output and not run_args.include? :return_output
        FileUtils.rm("#{ConfigManager.package_root}/stdout")
        FileUtils.rm("#{ConfigManager.package_root}/stderr")
      end
      res if run_args.include? :return_output
    end
  end
end
