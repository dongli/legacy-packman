module PACKMAN
  class RunManager
    def self.delegated_methods
      [:append_env, :change_env, :clean_env]
    end

    @@ld_library_pathes = []
    @@bashrc_pathes = []
    @@envs = {}

    def self.append_ld_library_path path
      @@ld_library_pathes << path if not @@ld_library_pathes.include? path
    end

    def self.clean_ld_library_path
      @@ld_library_pathes.clear
    end

    def self.append_env env, options = nil
      options = [options] if not options or options.class != Array
      idx = env.index('=')
      key = env[0, idx]
      value = env[idx+1..-1]
      if @@envs.has_key? key and not options.include? :ignore
        CLI.report_error "Environment #{CLI.red key} has been set!"
      else
        @@envs[key] = value
      end
    end

    def self.change_env env
      idx = env.index('=')
      key = env[0, idx]
      value = env[idx+1..-1]
      @@envs[key] = value
    end

    def self.append_bashrc_path path
      @@bashrc_pathes << path if not @@bashrc_pathes.include? path
    end

    def self.clean_bashrc_path
      @@bashrc_pathes.clear
    end

    def self.clean_env
      @@envs.clear
    end

    def self.default_command_prefix
      cmd_str = ''
      # Handle PACKMAN installed compiler.
      if CompilerManager.active_compiler_set.info.has_key? :installed_by_packman
        compiler_prefix = PACKMAN.prefix CompilerManager.active_compiler_set.info[:installed_by_packman]
        append_bashrc_path("#{compiler_prefix}/bashrc")
      end
      # Handle customized bashrc.
      rpath = []
      if not @@bashrc_pathes.empty?
        @@bashrc_pathes.each do |bashrc_path|
          # Note: Use '.' instead of 'source', since Ruby system seems invoke a dash not fully bash!
          cmd_str << ". #{bashrc_path} && "
          tmp = File.open(bashrc_path).read.match(/export \w+_RPATH="(.*)"/)
          rpath << tmp[1] if tmp
        end
      end
      cmd_str << "LD_RUN_PATH='#{rpath.join(':')}' " if not rpath.empty?
      # Handle customized LD_LIBRARY_PATH.
      if not @@ld_library_pathes.empty?
        case OS.type
        when :Darwin
          cmd_str << 'DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:'
        when :Linux
          cmd_str << 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'
        end
        cmd_str << @@ld_library_pathes.join(':')
        cmd_str << ' '
      end
      # Handle compilers. Check if the @@envs has already defined them.
      CompilerManager.active_compiler_set.info.each do |language, compiler_info|
        next if language == :installed_by_packman
        case language
        when 'c'
          cmd_str << "CC=#{compiler_info[:command]} " if not @@envs.has_key? 'CC'
        when 'c++'
          cmd_str << "CXX=#{compiler_info[:command]} " if not @@envs.has_key? 'CXX'
        when 'fortran'
          cmd_str << "F77=#{compiler_info[:command]} " if not @@envs.has_key? 'F77'
          cmd_str << "FC=#{compiler_info[:command]} " if not @@envs.has_key? 'FC'
        end
      end
      # Handle customized environment variables.
      if not @@envs.empty?
        @@envs.each do |key, value|
          cmd_str << "#{key}=#{value} "
        end
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
      cmd_str << "#{cmd_args} "
      if not CommandLine.has_option? '-verbose'
        cmd_str << "1> #{ConfigManager.package_root}/stdout 2> #{ConfigManager.package_root}/stderr"
      end
      print "#{CLI.blue '==>'} "
      if CommandLine.has_option? '-debug'
        print "#{cmd_str}\n"
      else
        print "#{CLI.truncate("#{cmd} #{args.join(' ')}")}\n"
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
