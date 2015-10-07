module PACKMAN
  module Shell
    class Env
      def self.delegated_methods
        [:append_env, :prepend_env, :reset_env, :clear_env, :has_env?,
         :export_env, :env_keys, :handle_unlinked]
      end

      def self.init
        @@customized_env = {}
      end

      def self.append_env keys, value, separator = nil
        i = [CompilerManager.active_compiler_set_index]
        @@customized_env[i] ||= {}
        separator ||= ' '
        value = value.to_s
        Array(keys).each do |key|
          old = @@customized_env[i][key]
          if old.nil? || old.empty?
            @@customized_env[i][key] = value
          else
            @@customized_env[i][key] = old+separator+value if not old.include? value
          end
        end
      end

      def self.prepend_env keys, value, separator = ' '
        i = [CompilerManager.active_compiler_set_index]
        @@customized_env[i] ||= {}
        value = value.to_s
        Array(keys).each do |key|
          old = @@customized_env[i][key]
          if old.nil? || old.empty?
            @@customized_env[i][key] = value
          else
            @@customized_env[i][key] = value+separator+old if not old.include? value
          end
        end
      end

      def self.reset_env key, value = nil
        i = [CompilerManager.active_compiler_set_index]
        @@customized_env[i] ||= {}
        @@customized_env[i][key] = value
      end

      def self.clear_env
        @@customized_env.clear
      end

      def self.[] key
        i = [CompilerManager.active_compiler_set_index]
        @@customized_env[i] ||= {}
        @@customized_env[i][key]
      end

      def self.env_keys
        i = [CompilerManager.active_compiler_set_index]
        @@customized_env[i] ||= {}
        @@customized_env[i].keys
      end

      def self.has_env? key
        i = [CompilerManager.active_compiler_set_index]
        @@customized_env[i] ||= {}
        @@customized_env[i].has_key? key
      end

      def self.export_env key
        i = [CompilerManager.active_compiler_set_index]
        @@customized_env[i] ||= {}
        if @@customized_env[i].has_key? key
          "export #{key}=\"#{@@customized_env[i][key]}\""
        else
          CLI.report_error "Environment variable #{CLI.red key} has not been set!"
        end
      end

      def self.handle_unlinked *packages
        packages.each do |package_class|
          append_env 'CPPFLAGS', "-I#{package_class.inc}"
          append_env 'LDFLAGS', "-L#{package_class.lib} #{PACKMAN.os.generate_rpaths(package_class.prefix, :wrap_flag).join(' ')}"
        end
      end
    end
  end
end
