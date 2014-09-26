module PACKMAN
  class RunManager
    @@ld_library_pathes = []
    @@bashrc_pathes = []
    @@envs = {}

    def self.append_ld_library_path path
      @@ld_library_pathes << path if not @@ld_library_pathes.include? path
    end

    def self.clean_ld_library_path
      @@ld_library_pathes.clear
    end

    def self.append_env env
      idx = env.index('=')
      key = env[0, idx]
      value = env[idx+1..-1]
      if @@envs.has_key? key
        PACKMAN::CLI.report_error "Environment #{PACKMAN::CLI.red key} has been set!"
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
      if Package.compiler_set.has_key? 'installed_by_packman'
        compiler_prefix = Package.prefix(Package.compiler_set['installed_by_packman'])
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
      cmd_str << "LD_RUN_PATH='#{rpath.join(':')}' "
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
      Package.compiler_set.each do |language, compiler|
        case language
        when 'c'
          cmd_str << "CC=#{compiler} " if not @@envs.has_key? 'CC'
        when 'c++'
          cmd_str << "CXX=#{compiler} " if not @@envs.has_key? 'CXX'
        when 'fortran'
          cmd_str << "F77=#{compiler} " if not @@envs.has_key? 'F77'
          cmd_str << "FC=#{compiler} " if not @@envs.has_key? 'FC'
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
      if build_helper and build_helper.should_insert_before_command?
        # Handle compiler default flags.
        Package.compiler_set.each do |language, compiler|
          next if language == 'installed_by_packman'
          cmd_str << "#{build_helper.wrap_flags language, PACKMAN.default_flags(language, compiler)} "
        end
      end
      cmd_str << " #{cmd} "
      cmd_str << "#{args.join(' ')} "
      if build_helper and build_helper.should_insert_after_command?
        # Handle compiler default flags.
        Package.compiler_set.each do |language, compiler|
          next if language == 'installed_by_packman'
          cmd_str << "#{build_helper.wrap_flags language, PACKMAN.default_flags(language, compiler)} "
        end
      end
      if not PACKMAN::CommandLine.has_option? '-verbose'
        cmd_str << "1> #{ConfigManager.package_root}/stdout 2> #{ConfigManager.package_root}/stderr"
      end
      print "#{PACKMAN::CLI.blue '==>'} #{PACKMAN::CLI.truncate("#{cmd} #{args.join(' ')}")}\n"
      system cmd_str
      if not $?.success?
        info =  "PATH: #{FileUtils.pwd}\n"
        info << "Command: #{cmd_str}\n"
        info << "Return: #{$?}\n"
        if not PACKMAN::CommandLine.has_option? '-verbose'
          info << "Standard output: #{ConfigManager.package_root}/stdout\n"
          info << "Standard error: #{ConfigManager.package_root}/stderr\n"
        end
        PACKMAN::CLI.report_error "Failed to run the following command:\n"+info
      end
      if not PACKMAN::CommandLine.has_option? '-verbose'
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

  def self.slim_run cmd, *args
    res = `#{cmd} #{args.join(' ')} 1> /dev/null 2>&1`
    raise "Command failed!" if not $?.success?
    return res
  end

  def self.append_env env
    RunManager.append_env env
  end

  def self.change_env env
    RunManager.change_env env
  end

  def self.clean_env
    RunManager.clean_env
  end
end
