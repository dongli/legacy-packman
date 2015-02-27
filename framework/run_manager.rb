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
      # Handle compilers. Check if customized environment variables have already defined them.
      CompilerManager.active_compiler_set.info.each do |language, compiler_info|
        next if language == :installed_by_packman
        flags = PACKMAN.default_compiler_flags language
        flags << "#{PACKMAN.customized_compiler_flags language}"
        case language
        when 'c'
          PACKMAN.append_env 'CC', compiler_info[:command] if not PACKMAN.has_env? 'CC'
          flag_name = 'CFLAGS'
        when 'c++'
          PACKMAN.append_env 'CXX', compiler_info[:command] if not PACKMAN.has_env? 'CXX'
          flag_name = 'CXXFLAGS'
        when 'fortran'
          PACKMAN.append_env 'F77', compiler_info[:command] if not PACKMAN.has_env? 'F77'
          PACKMAN.append_env 'FC', compiler_info[:command] if not PACKMAN.has_env? 'FC'
          flag_name = 'FCFLAGS'
        end
        PACKMAN.append_env flag_name, flags
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
      print "#{CLI.blue '==>'} "
      cmd_str << "#{cmd_args} "
      if CommandLine.has_option? '-debug'
        print "#{cmd_str}\n"
      else
        print "#{CLI.truncate("#{cmd} #{cmd_args}")}\n"
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
