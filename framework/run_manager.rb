module PACKMAN
  class RunManager
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
          Shell::Env.append_env 'LD_RUN_PATH', tmp[1], ':'
        end
      end
      # Handle compilers. Check if customized environment variables have already defined them.
      CompilerManager.active_compiler_set.info.each do |language, compiler_info|
        next if language == :installed_by_packman
        case language
        when 'c'
          Shell::Env.append_env 'CC', compiler_info[:command] if not Shell::Env.has_variable? 'CC'
        when 'c++'
          Shell::Env.append_env 'CXX', compiler_info[:command] if not Shell::Env.has_variable? 'CXX'
        when 'fortran'
          Shell::Env.append_env 'F77', compiler_info[:command] if not Shell::Env.has_variable? 'F77'
          Shell::Env.append_env 'FC', compiler_info[:command] if not Shell::Env.has_variable? 'FC'
        end
      end
      # Handle customized environment variables.
      Shell::Env.variables.each do |variable|
        cmd_str << "#{Shell::Env.export_env variable} && "
      end
      return cmd_str
    end

    def self.run build_helper, cmd, *args
      cmd_str = default_command_prefix
      cmd_args = args.join(' ')
      if build_helper and build_helper.should_insert_before_command?
        # Handle compiler default flags.
        CompilerManager.active_compiler_set.info.each_key do |language|
          next if language == :installed_by_packman
          flags = PACKMAN.default_compiler_flags language
          tmp = PACKMAN.customized_compiler_flags language
          flags << tmp if tmp
          cmd_str << "#{build_helper.wrap_flags language, flags, cmd_args} "
        end
      end
      cmd_str << " #{cmd} "
      if build_helper and build_helper.should_insert_after_command?
        # Handle compiler default flags.
        CompilerManager.active_compiler_set.info.each_key do |language|
          next if language == :installed_by_packman
          flags = PACKMAN.default_compiler_flags language
          tmp = PACKMAN.customized_compiler_flags language
          flags << tmp if tmp
          cmd_str << "#{build_helper.wrap_flags language, flags, cmd_args} "
        end
      end
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

  def self.run cmd, *args
    case cmd
    when /configure/
      RunManager.run AutotoolHelper, cmd, *args
    when /cmake/
      RunManager.run CmakeHelper, cmd, *args
    else
      RunManager.run nil, cmd, *args
    end
  end
end
