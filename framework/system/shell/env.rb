module PACKMAN
  module Shell
    class Env
      def self.delegated_methods
        [:append_env, :prepend_env, :reset_env, :clear_env, :has_env?,
         :export_env, :env_keys, :append_source, :prepend_source, :clear_source]
      end

      def self.init
        @@customized_env = {}
        @@customized_source = []
      end

      def self.append_env keys, value, separator = nil
        separator ||= ' '
        value = value.to_s
        Array(keys).each do |key|
          old = @@customized_env[key]
          if old.nil? || old.empty?
            @@customized_env[key] = value
          else
            @@customized_env[key] = old+separator+value if not old.include? value
          end
        end
      end

      def self.append_source paths
        Array(paths).each do |path|
          @@customized_source << path if not @@customized_source.include? path
        end
      end

      def self.prepend_env keys, value, separator = ' '
        value = value.to_s
        Array(keys).each do |key|
          old = @@customized_env[key]
          if old.nil? || old.empty?
            @@customized_env[key] = value
          else
            @@customized_env[key] = value+separator+old if not old.include? value
          end
        end
      end

      def self.prepend_source paths
        Array(paths).each do |path|
          @@customized_source.unshift path if not @@customized_source.include? path
        end
      end

      def self.reset_env key, value
        @@customized_env[key] = value
      end

      def self.clear_env
        @@customized_env.clear
      end

      def self.clear_source
        @@customized_source.clear
      end

      def self.[] key
        @@customized_env[key]
      end

      def self.env_keys
        @@customized_env.keys
      end

      def self.sources
        @@customized_source
      end

      def self.has_env? key
        @@customized_env.has_key? key
      end

      def self.export_env key
        if @@customized_env.has_key? key
          "export #{key}=\"#{@@customized_env[key]}\""
        else
          CLI.report_error "Environment variable #{CLI.red key} has not been set!"
        end
      end
    end
  end
end