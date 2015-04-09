module PACKMAN
  module Shell
    class Env
      def self.delegated_methods
        [:append_env, :prepend_env, :reset_env, :clear_env, :has_env?,
         :export_env, :env_keys, :shell_sources,
         :append_shell_source, :prepend_shell_source, :clear_shell_source,
         :set_cppflags_and_ldflags]
      end

      def self.init
        @@customized_env = {}
        @@customized_shell_source = {}
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

      def self.append_shell_source paths
        i = [CompilerManager.active_compiler_set_index]
        @@customized_shell_source[i] ||= []
        Array(paths).each do |path|
          @@customized_shell_source[i] << path if not @@customized_shell_source[i].include? path
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

      def self.prepend_shell_source paths
        i = [CompilerManager.active_compiler_set_index]
        @@customized_shell_source[i] ||= []
        Array(paths).each do |path|
          @@customized_shell_source[i].unshift path if not @@customized_shell_source[i].include? path
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

      def self.clear_shell_source
        @@customized_shell_source.clear
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

      def self.shell_sources
        i = [CompilerManager.active_compiler_set_index]
        @@customized_shell_source[i] ||= []
        @@customized_shell_source[i]
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

      def self.set_cppflags_and_ldflags libs
        libs.each do |lib|
          append_env 'CPPFLAGS', "-I#{PACKMAN.prefix lib}/include"
          append_env 'LDFLAGS', "-L#{PACKMAN.prefix lib}/lib"
        end
      end
    end
  end
end
