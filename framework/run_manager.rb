module PACKMAN
  class RunManager
    @@ld_library_pathes = []
    @@bashrc_pathes = []
    @@envs = []

    def self.append_ld_library_path(path)
      @@ld_library_pathes << path if not @@ld_library_pathes.include? path
    end

    def self.clean_ld_library_path
      @@ld_library_pathes.clear
    end

    def self.append_env(env)
      @@envs << env if not @@envs.include? env
    end

    def self.append_bashrc_path(path)
      @@bashrc_pathes << path if not @@bashrc_pathes.include? path
    end

    def self.clean_bashrc_path
      @@bashrc_pathes.clear
    end

    def self.clean_env
      @@envs.clear
    end

    def self.default_command_prefix(cmd, *args)
      cmd_str = ''
      # Handle PACKMAN installed compiler.
      if Package.compiler_set.has_key? 'installed_by_packman'
        compiler_prefix = Package.prefix(Package.compiler_set['installed_by_packman'])
        append_bashrc_path("#{compiler_prefix}/bashrc")
      end
      # Handle customized bashrc.
      if not @@bashrc_pathes.empty?
        @@bashrc_pathes.each do |bashrc_path|
          # Note: Use '.' instead of 'source', since Ruby system seems invoke a dash not fully bash!
          cmd_str << ". #{bashrc_path} && "
        end
      end
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
      # Handle compilers.
      Package.compiler_set.each do |language, compiler|
        case language
        when 'c'
          cmd_str << "CC=#{compiler} "
        when 'c++'
          cmd_str << "CXX=#{compiler} "
        when 'fortran'
          cmd_str << "FC=#{compiler} "
          cmd_str << "F77=#{compiler} "
        end
      end
      # Handle customized environment variables.
      if not @@envs.empty?
        @@envs.each do |env|
          cmd_str << "#{env} "
        end
      end
      cmd_str << " #{cmd} "
      cmd_str << args.join(' ')
      return cmd_str
    end

    def self.run(build_helper, cmd, *args)
      cmd_str = default_command_prefix cmd, *args
      if build_helper
        # Handle compiler default flags.
        Package.compiler_set.each do |language, compiler|
          cmd_str << build_helper.wrap_flags(language, CompilerHelper.default_flags(language, compiler))
        end
      end
      cmd_str << " 1> #{ConfigManager.package_root}/stdout 2> #{ConfigManager.package_root}/stderr"
      print "#{PACKMAN::Tty.blue}==>#{PACKMAN::Tty.reset} #{PACKMAN::Tty.truncate("#{cmd} #{args.join(' ')}")}\n"
      system cmd_str
      if not $?.success?
        PACKMAN.report_error "Failed to run the following command:\n"+
          "PATH: #{FileUtils.pwd}\n"+
          "Command: #{cmd_str}\n"+
          "Return: #{$?}\n"+
          "Standard output: #{ConfigManager.package_root}/stdout\n"+
          "Standard error: #{ConfigManager.package_root}/stderr\n"
      end
      FileUtils.rm("#{ConfigManager.package_root}/stdout")
      FileUtils.rm("#{ConfigManager.package_root}/stderr")
    end
  end

  def self.autotool(cmd, *args)
    RunManager.run PACKMAN::AutotoolHelper, cmd, *args
  end

  def self.cmake(cmd, *args)
    RunManager.run PACKMAN::CmakeHelper, cmd, *args
  end

  def self.run(cmd, *args)
    RunManager.run nil, cmd, *args
  end

  def self.slim_run(cmd, *args)
    res = `#{cmd} #{args.join(' ')} 1> /dev/null 2>&1`
    raise "Command failed!" if not $?.success?
    return res
  end

  def self.append_env(env)
    RunManager.append_env env
  end

  def self.clean_env
    RunManager.clean_env
  end
end
