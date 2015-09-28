module PACKMAN
  module Files
    class ShellConfig
      def self.write *options
        PACKMAN.write_file "#{ConfigManager.install_root}/packman.bashrc", <<-EOT.keep_indent
          ROOT=$(cd $(dirname $BASH_SOURCE) && pwd)/#{ConfigManager.defaults['compiler_set_index']}
          export PATH="$ROOT/bin:$PATH"
          export #{PACKMAN.ld_library_path_name}="$ROOT/lib:#{PACKMAN.ld_library_path_name}"
          export MANPATH="$ROOT/share/man:$MANPATH"
        EOT
      end
    end
  end
end
