module PACKMAN
  class RunManager
    def self.delegated_methods
      [:run]
    end

    def self.default_command_prefix
      cmd_str = ''
      # Handle PACKMAN installed compiler.
      if CompilerManager.active_compiler_set.info.has_key? :installed_by_packman
        compiler_prefix = PACKMAN.prefix CompilerManager.active_compiler_set.info[:installed_by_packman]
        Shell::Env.append_source "#{compiler_prefix}/bashrc"
      end
      # Handle customized bashrc.
      if not Shell::Env.sources.empty?
        Shell::Env.sources.each do |source|
          # Note: Use '.' instead of 'source', since Ruby system seems invoke a dash not fully bash!
          cmd_str << ". #{source} && "
          tmp = File.open(source).read.match(/\w+_RPATH="(.*)"/)
          # Add RPATH options to ensure the correct libraries are linked.
          next if not tmp
          tmp[1].split(':').each do |rpath|
            PACKMAN.append_env 'LDFLAGS', PACKMAN.compiler_flag('c', :rpath).(rpath)
          end
        end
      end
      # Handle compilers.
      CompilerManager.active_compiler_set.info.each do |language, compiler_info|
        next if language == :installed_by_packman
        flags = PACKMAN.default_compiler_flags language
        PACKMAN.append_env PACKMAN.compiler_flags_env_name(language), flags
        case language
        when 'c'
          PACKMAN.reset_env 'CC', compiler_info[:command]
        when 'c++'
          PACKMAN.reset_env 'CXX', compiler_info[:command]
        when 'fortran'
          PACKMAN.reset_env 'F77', compiler_info[:command]
          PACKMAN.reset_env 'FC', compiler_info[:command]
        end
      end
      # Handle customized environment variables.
      PACKMAN.env_keys.each do |key|
        cmd_str << "#{Shell::Env.export_env key} && "
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
  end
end
