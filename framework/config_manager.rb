module PACKMAN
  class ConfigManager
    @@valid_keys = %W[
      package_root
      install_root
      active_compiler_set
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
    end

    def self.compiler_sets
      @@compiler_sets
    end

    def self.compiler_sets=(compiler_sets)
      @@compiler_sets = compiler_sets
    end

    def self.package(name, spec)
      name = name.capitalize.to_sym
      @@packages[name] = spec
      if not PACKMAN.class_defined? name
        PACKMAN.report_error "Unknown package #{PACKMAN::Tty.red}#{name}#{PACKMAN::Tty.reset}!"
      end
    end

    def self.packages
      @@packages
    end

    def self.parse(file_path)
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
        PACKMAN.report_error "A configure file (\"#{file_path}\") exists in current directory!"
      end
      File.open(file_path, 'w') do |file|
        file << "package_root = \"...\"\n"
        file << "install_root = \"...\"\n"
        file << "active_compiler_set = ...\n"
        file << "compiler_set_0 = {\n"
        file << "  \"c\" => \"...\",\n"
        file << "  \"c++\" => \"...\",\n"
        file << "  \"fortran\" => \"...\"\n"
        file << "}\n"
        file << "package_... = {\n"
        file << "  \"compiler_set\" => [...]\n"
        file << "}\n"
      end
    end
  end
end
