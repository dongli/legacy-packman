module PACKMAN
  module Shell
    class Env
      def self.delegated_methods
        [:append_env, :prepend_env, :reset_env, :clear_env, :has_env?,
         :export_env, :env_keys, :set_cppflags_and_ldflags]
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

      def self.set_cppflags_and_ldflags libs
        libs.each do |lib|
          prefix = PACKMAN.prefix lib
          append_env 'CPPFLAGS', "-I#{prefix}/include"
          append_env 'LDFLAGS', "-L#{prefix}/lib"
          # TODO: Some 64-bit machines need 'lib64'! Find a better solution.
          append_env 'LDFLAGS', "-L#{prefix}/lib64" if Dir.exist? "#{prefix}/lib64"
        end
      end

      def self.filter_ld_library_path
        return if not ENV[PACKMAN.ld_library_path_name]
        paths = ENV[PACKMAN.ld_library_path_name].split ':'
        paths.delete_if { |path| path =~ /#{ConfigManager.install_root}/ }
        append_env PACKMAN.ld_library_path_name, paths.join(':')
      end
    end
  end
end
