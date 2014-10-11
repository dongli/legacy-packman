module PACKMAN
  class ConfigManager
    @@valid_keys = %W[
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
    ]

    @@packages = {}

    def self.init
      @@valid_keys.each do |key|
        class_eval "@@#{key} = nil"
        class_eval "def self.#{key}=(value); @@#{key} = value; end"
        class_eval "def self.#{key}; @@#{key}; end"
      end
      # Set default values.
      @@use_ftp_mirror = 'no'
      @@download_command = :curl
    end

    def self.compiler_sets
      @@compiler_sets
    end

    def self.compiler_sets=(compiler_sets)
      @@compiler_sets = compiler_sets
    end

    def self.package(name, spec)
      # Default install specifications.
      spec['use_binary'] = false if not spec.has_key? 'use_binary'
      spec['compiler_set'] = [spec['compiler_set']] if spec['compiler_set'].class == Fixnum
      name = name.capitalize.to_sym
      @@packages[name] = spec
      if not Package.defined? name
        CLI.report_error "Unknown package #{CLI.red name}!"
      end
    end

    def self.packages
      @@packages
    end

    def self.parse
      file_path = CommandLine.config_file
      return if not file_path
      if not File.exist? file_path
        CLI.report_error "Configuation file #{CLI.red file_path} does not exist!"
      end
      config = File.open(file_path, 'r').read
      # Modify the config to fulfill the needs of Ruby.
      @@valid_keys.each do |key|
        config.gsub!(/^ *#{key} *=/, "self.#{key}=")
      end
      config.gsub!(/^ *package_(\w+) *=/, 'self.package "\1",')
      class_eval config
      PACKMAN.expand_tilde @@package_root
      PACKMAN.expand_tilde @@install_root
      @@download_command = @@download_command.to_sym
      @@compiler_sets = []
      ( self.methods.select { |m| m.to_s =~ /compiler_set_\d$/ } ).each do |m|
        compiler_set = self.method(m).call
        @@compiler_sets << compiler_set if compiler_set != nil
      end
      # Check if defaults has been set.
      if not @@defaults and not CommandLine.subcommand == :config
        msg = <<EOT
Defaults section has not been set in #{CLI.red file_path}!
Example:
#{CLI.red '==>'} defaults = {
#{CLI.red '==>'}   "compiler_set" => ...,
#{CLI.red '==>'}   "mpi" => "..."
#{CLI.red '==>'} }
EOT
        CLI.report_error msg
      end
    end

    def self.template(file_path)
      if File.exist? file_path
        CLI.report_error "A configure file is needed "+
          "and #{CLI.red file_path} exists, consider to use it!"
      end
      File.open(file_path, 'w') do |file|
        file << <<-EOT
package_root = "..."
install_root = "..."
use_ftp_mirror = "no"
defaults = {
  "compiler_set" => 0,
  "mpi" => "mpich"
}
compiler_set_0 = {
  "c" => "...",
  "c++" => "...",
  "fortran" => "..."
}
package_... = {
  "compiler_set" => [...]
}
        EOT
      end
    end

    def self.write
      File.open(CommandLine.config_file, 'w') do |file|
        file << "package_root = \"#{package_root}\"\n"
        file << "install_root = \"#{install_root}\"\n"
        file << "use_ftp_mirror = \"#{use_ftp_mirror}\"\n"
        file << "defaults = {\n"
        str = []
        defaults.each do |key, value|
          case key
          when /compiler_set/
            str << "  \"#{key}\" => #{value}"
          else
            str << "  \"#{key}\" => \"#{value}\""
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
        packages.each do |package_name, install_spec|
          file << "package_#{package_name.to_s.downcase} = {\n"
          str = []
          install_spec.each do |key, value|
            next if key == 'use_binary' or not value
            case key
            when /(use_binary|compiler_set)/
              str << "  \"#{key}\" => #{value}"
            else
              str << "  \"#{key}\" => \"#{value}\""
            end
          end
          file << "#{str.join(",\n")}\n" if not str.empty?
          file << "}\n"
        end
      end
    end
  end
end
