module PACKMAN
  class ConfigManager
    def self.delegated_methods
      [:package_root, :install_root, :download_command]
    end

    PermittedKeys = %W[
      package_root
      install_root
      defaults
      use_ftp_mirror
      download_command
      compiler_set_0
      compiler_set_1
      compiler_set_2
      compiler_set_3
      compiler_set_4
    ].freeze

    def self.init
      PermittedKeys.each do |key|
        class_eval "@@#{key} = nil"
        class_eval "def self.#{key}=(value); @@#{key} = value; end"
        class_eval "def self.#{key}; @@#{key}; end"
      end
      # Set default values.
      @@use_ftp_mirror = 'no'
      @@download_command = :curl
      @@defaults = {}
    end

    def self.parse
      return if CommandLine.subcommand == :config
      file_path = CommandLine.config_file
      return if not file_path
      if not File.exist? file_path
        CLI.report_error "Configuation file #{CLI.red file_path} does not exist!"
      end
      config = File.open(file_path, 'r').read
      # Modify the config to fulfill the needs of Ruby.
      PermittedKeys.each do |key|
        config.gsub!(/^ *#{key} *=/, "self.#{key}=")
      end
      config.gsub!(/^\s*['"](\w+)['"]\s=>/, '  :\1 =>')
      begin
        class_eval config
      rescue SyntaxError => e
        CLI.report_error "Failed to parse #{CLI.red CommandLine.config_file}!\n#{e}"
      end
      if package_root == '<CHANGE ME>'
        CLI.report_error "You haven't modified #{CLI.red 'package_root'} in #{CommandLine.config_file}!"
      end
      if install_root == '<CHANGE ME>'
        CLI.report_error "You haven't modified #{CLI.red 'install_root'} in #{CommandLine.config_file}!"
      end
      @@package_root = File.expand_path @@package_root
      @@install_root = File.expand_path @@install_root
      PACKMAN.mkdir @@package_root if not Dir.exist? @@package_root
      PACKMAN.mkdir @@install_root if not Dir.exist? @@install_root
      @@download_command = @@download_command.to_sym
      command_hash_array = []
      ( self.methods.select { |m| m.to_s =~ /compiler_set_\d$/ } ).each do |m|
        command_hash = self.method(m).call
        if command_hash != nil
          if command_hash.has_key? :installed_by_packman
            command_hash[:installed_by_packman].downcase!
          end
          command_hash.each do |key, value|
            if value == '<CHANGE ME>'
              CLI.report_error "You haven't modified #{CLI.red key} compiler in #{CommandLine.config_file}!"
            end
          end
          command_hash_array << command_hash
        end
      end
      if command_hash_array.empty?
        CLI.report_error "There is no compiler set defined in #{CommandLine.config_file}!"
      end
      CompilerManager.set_compiler_sets command_hash_array
      CompilerManager.activate_default_compiler_set
      # Check if defaults has been set.
      if defaults.empty?
        msg = <<-EOT.keep_indent
          Defaults section has not been set in #{CLI.red file_path}!
          Example:
          #{CLI.red '==>'} defaults = {
          #{CLI.red '==>'}   :compiler_set_index => 0,
          #{CLI.red '==>'}   :mpi => 'mpich'
          #{CLI.red '==>'} }
        EOT
        CLI.report_error msg.chomp
      end
      # Report configuation.
      # - FTP mirror.
      if [ :collect, :install ].include? CommandLine.subcommand
        if not @@use_ftp_mirror == 'no'
          CLI.report_notice "Use FTP mirror #{CLI.blue @@use_ftp_mirror}."
        end
      end
      # - Compilers and their flags.
      print_compiler_sets if [:install].include? CommandLine.subcommand
    end

    def self.print_compiler_sets
      for i in 0..CompilerManager.compiler_sets.size-1
        CLI.report_notice "Compiler set #{CLI.green i}:"
        CompilerManager.compiler_sets[i].compilers.each do |language, compiler|
          next if not compiler
          print "#{CLI.blue '==>'} #{language}: #{compiler.command} #{compiler.default_flags[language]}\n"
          if compiler.mpi_wrapper
            print "#{CLI.blue '==>'} #{language} MPI wrapper: #{compiler.mpi_wrapper}\n"
          end
        end
      end
    end

    def self.template file_path
      if File.exist? file_path
        CLI.report_error "A configure file is needed "+
          "and #{CLI.red file_path} exists, consider to use it!"
      end
      default_compilers = {}
      File.open(file_path, 'w') do |file|
        file << <<-EOT.keep_indent
          package_root = '~/.packman/packages'
          install_root = '~/.packman'
          use_ftp_mirror = 'no'
          download_command = 'curl'
          defaults = {
            :compiler_set_index => 0,
            :mpi => 'mpich'
          }
          compiler_set_0 = {
        EOT
        case PACKMAN.os.type
        when :Mac
          if PACKMAN.os.check(:Xcode) and PACKMAN.os.check(:CommandLineTools)
            default_compilers[:c] = 'clang'
            default_compilers[:cxx] = 'clang++'
          end
        else
          default_compilers[:c] = 'gcc' if PACKMAN.does_command_exist? 'gcc'
          default_compilers[:cxx] = 'g++' if PACKMAN.does_command_exist? 'g++'
          default_compilers[:fortran] = 'gfortran' if PACKMAN.does_command_exist? 'gfortran'
        end
        file << "  :c => '#{default_compilers[:c]}'" if default_compilers.has_key? :c
        file << ",\n  :cxx => '#{default_compilers[:cxx]}'" if default_compilers.has_key? :cxx
        file << ",\n  :fortran => '#{default_compilers[:fortran]}'" if default_compilers.has_key? :fortran
        file << "\n}"
      end
      if not CommandLine.has_option? '-silent'
        CLI.report_notice "#{CLI.green file_path} is generated. Please revise the following settings:\n"+
          "#{CLI.blue 'package_root'}     = #{CLI.red '~/.packman/packages'}\n"+
          "#{CLI.blue 'install_root'}     = #{CLI.red '~/.packman'}\n"+
          "#{CLI.blue 'C compiler'}       = #{CLI.red default_compilers[:c]}\n"+
          "#{CLI.blue 'C++ compiler'}     = #{CLI.red default_compilers[:cxx]}\n"+
          "#{CLI.blue 'Fortran compiler'} = #{CLI.red default_compilers[:fortran] || 'NONE'}"
        CLI.pause :message => '[Press ANY key]'
      end
    end

    def self.write file_path = nil
      file_path = file_path ? file_path : CommandLine.config_file
      File.open(file_path, 'w') do |file|
        file << "package_root = '#{package_root}'\n"
        file << "install_root = '#{install_root}'\n"
        file << "use_ftp_mirror = '#{use_ftp_mirror}'\n"
        file << "download_command = '#{download_command}'\n"
        file << "defaults = {\n"
        str = []
        defaults.each do |key, value|
          if value.class == String
            str << "  :#{key} => '#{value}'"
          else
            str << "  :#{key} => #{value}"
          end
        end
        file << "#{str.join(",\n")}\n}\n"
        for i in 0..CompilerManager.compiler_sets.size-1
          compiler_set = CompilerManager.compiler_sets[i]
          file << "compiler_set_#{i} = {\n"
          str = []
          str << "  :installed_by_packman => '#{compiler_set.package_name}'" if compiler_set.installed_by_packman?
          compiler_set.compilers.each do |language, compiler|
            next if not compiler
            str << "  :#{language} => '#{compiler.command}'"
            str << "  :mpi_#{language} => '#{compiler.mpi_wrapper}'" if compiler.mpi_wrapper
          end
          file << "#{str.join(",\n")}\n"
          file << "}\n"
        end
      end
    end
  end
end
