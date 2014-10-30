module PACKMAN
  class ConfigManager
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
      @@compiler_sets = []
      @@package_options = {}
    end

    def self.compiler_sets
      @@compiler_sets
    end

    def self.compiler_sets= compiler_sets
      @@compiler_sets = compiler_sets
    end

    def self.package_options
      @@package_options ||= {}
    end

    def self.package name, options
      name = name.capitalize.to_sym
      @@package_options[name] = options
      if not Package.defined? name
        CLI.report_error "Unknown package #{CLI.red name} in #{CLI.red CommandLine.config_file}!"
      end
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
      config.gsub!(/^ *package_(\w+) *=/, 'self.package "\1",')
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
      PACKMAN.expand_tilde @@package_root
      PACKMAN.expand_tilde @@install_root
      PACKMAN.mkdir @@package_root if not Dir.exist? @@package_root
      PACKMAN.mkdir @@install_root if not Dir.exist? @@install_root
      @@download_command = @@download_command.to_sym
      @@compiler_sets = []
      ( self.methods.select { |m| m.to_s =~ /compiler_set_\d$/ } ).each do |m|
        compiler_set = self.method(m).call
        if compiler_set != nil
          compiler_set.each do |key, value|
            if value == '<CHANGE ME>'
              CLI.report_error "You haven't modified #{CLI.red key} compiler in #{CommandLine.config_file}!"
            end
          end
          CompilerManager.check_compilers compiler_set
          @@compiler_sets << compiler_set
        end
      end
      # Check if defaults has been set.
      if defaults.empty?
        msg = <<EOT
Defaults section has not been set in #{CLI.red file_path}!
Example:
#{CLI.red '==>'} defaults = {
#{CLI.red '==>'}   "compiler_set_index" => 0,
#{CLI.red '==>'}   "mpi" => "mpich"
#{CLI.red '==>'} }
EOT
        CLI.report_error msg.chomp
      end
      # Report configuation.
      # - FTP mirror.
      if [:collect, :install].include? CommandLine.subcommand
        if not @@use_ftp_mirror == 'no'
          CLI.report_notice "Use FTP mirror #{CLI.blue @@use_ftp_mirror}."
        end
      end
      # - Compilers and their flags.
      CompilerManager.expand_packman_compiler_sets
      if [:install].include? CommandLine.subcommand
        for i in 0..ConfigManager.compiler_sets.size-1
          CLI.report_notice "Compiler set #{CLI.green i}:"
          ConfigManager.compiler_sets[i].each do |language, compiler|
            next if language == 'installed_by_packman'
            print "#{CLI.blue '==>'} #{language}: #{compiler} #{PACKMAN.default_compiler_flags language, compiler}\n"
          end
        end
      end
      ConfigManagerLegacy.check
    end

    def self.template file_path
      if File.exist? file_path
        CLI.report_error "A configure file is needed "+
          "and #{CLI.red file_path} exists, consider to use it!"
      end
      File.open(file_path, 'w') do |file|
        file << <<-EOT
package_root = "<CHANGE ME>"
install_root = "<CHANGE ME>"
use_ftp_mirror = "no"
defaults = {
  "compiler_set_index" => 0,
  "mpi" => "mpich"
}
compiler_set_0 = {
  "c" => "<CHANGE ME>",
  "c++" => "<CHANGE ME>",
  "fortran" => "<CHANGE ME>"
}
        EOT
      end
    end

    def self.write file_path = nil
      file_path = file_path ? file_path : CommandLine.config_file
      File.open(file_path, 'w') do |file|
        file << "package_root = \"#{package_root}\"\n"
        file << "install_root = \"#{install_root}\"\n"
        file << "use_ftp_mirror = \"#{use_ftp_mirror}\"\n"
        file << "defaults = {\n"
        str = []
        defaults.each do |key, value|
          if value.class == String
            str << "  \"#{key}\" => \"#{value}\""
          else
            str << "  \"#{key}\" => #{value}"
          end
        end
        file << "#{str.join(",\n")}\n}\n"
        for i in 0..compiler_sets.size-1
          file << "compiler_set_#{i} = {\n"
          str = []
          compiler_sets[i].each do |language, compiler|
            if language == 'installed_by_packman'
              str = ["  \"installed_by_packman\" => \"#{compiler.downcase}\""]
              break
            end
            str << "  \"#{language}\" => \"#{compiler}\""
          end
          file << "#{str.join(",\n")}\n"
          file << "}\n"
        end
        package_options.each do |package_name, options|
          package = Package.instance package_name
          file << "package_#{package_name.to_s.downcase} = {\n"
          str = []
          options.each do |key, value|
            next if value == PackageSpec.default_option_value(package.option_valid_types[key])
            case value
            when String
              str << "  \"#{key}\" => \"#{value}\""
            else
              str << "  \"#{key}\" => #{value}"
            end
          end
          file << "#{str.join(",\n")}\n" if not str.empty?
          file << "}\n"
        end
      end
    end

    def self.propagate_options_to package
      if package.master_package
        options = package_options[package.master_package]
      else
        options = package_options[package.class.to_s.to_sym]
      end
      return if not options or options.empty?
      for i in 0..package.options.size-1
        key = package.options.keys[i]
        next if not options.has_key? key
        value = options[key]
        package.update_option key, value
      end
    end
  end
end
