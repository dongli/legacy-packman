module PACKMAN
  class ConfigManager
    @@valid_keys = %W[
      package_root
      install_root
      defaults
      use_ftp_mirror
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
      if not PACKMAN::Package.defined? name
        PACKMAN::CLI.report_error "Unknown package #{PACKMAN::CLI.red name}!"
      end
    end

    def self.packages
      @@packages
    end

    def self.parse
      file_path = PACKMAN::CommandLine.config_file
      return if not file_path
      if not File.exist? file_path
        PACKMAN::CLI.report_error "Configuation file #{PACKMAN::CLI.red file_path} does not exist!"
      end
      config = File.open(file_path, 'r').read
      # Modify the config to fulfill the needs of Ruby.
      @@valid_keys.each do |key|
        config.gsub!(/^ *#{key} *=/, "self.#{key}=")
      end
      config.gsub!(/^ *package_(\w+) *=/, 'self.package "\1",')
      class_eval config
      @@compiler_sets = []
      ( self.methods.select { |m| m.to_s =~ /compiler_set_\d$/ } ).each do |m|
        compiler_set = self.method(m).call
        @@compiler_sets << compiler_set if compiler_set != nil
      end
    end

    def self.template(file_path)
      if File.exist? file_path
        PACKMAN::CLI.report_error "A configure file is needed "+
          "and #{PACKMAN::CLI.red file_path} exists, consider to use it!"
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
            when /use_mpi/
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
