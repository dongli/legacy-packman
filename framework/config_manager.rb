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
      @@packages[name.capitalize.to_sym] = spec
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
  end
end
