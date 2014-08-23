module PACKMAN
  class RunManager
    @@ld_library_pathes = []
    @@bashrc_pathes = []

    def self.append_ld_library_path(path)
      @@ld_library_pathes << path if not @@ld_library_pathes.include? path
    end

    def self.clean_ld_library_path
      @@ld_library_pathes.clear
    end

    def self.append_bashrc_path(path)
      @@bashrc_pathes << path if not @@bashrc_pathes.include? path
    end

    def self.clean_bashrc_path
      @@bashrc_pathes.clear
    end

    def self.run(cmd, *args)
      cmd_str = ''
      # Handle PACKMAN installed compiler.
      if Package.compiler_set.has_key?(:installed_by_packman)
        compiler_prefix = Package.prefix(Package.compiler_set[:installed_by_packman])
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
      cmd_str << " #{cmd} "
      cmd_str << args.join(' ')
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

  # Shortcuts.
  def self.run(cmd, *args)
    RunManager.run(cmd, *args)
  end

  def self.slim_run(cmd, *args)
    res = `#{cmd} #{args.join(' ')}`
    raise "Command failed!" if not $?.success?
    return res
  end
end