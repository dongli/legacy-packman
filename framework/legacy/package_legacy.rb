module PACKMAN
  class PackageLegacy
    def fix_gcc
      gcc = Package.instance :Gcc
      if Commands.is_package_installed? gcc, :silent
        begin
          PACKMAN.replace "#{PACKMAN.prefix gcc}/bashrc", {
            /export GCC_ROOT=.*$/ => '',
            /\$\{GCC_ROOT\}/ => "#{PACKMAN.prefix gcc}"
          }, :silent
          CLI.report_notice "Gcc bashrc file is fixed."
        rescue SystemExit
        end
      end
    end

    def fix_env_var_prefix
      Dir.foreach ConfigManager.install_root do |package_name|
        next if not Package.all_package_names.include? package_name
        dir = "#{ConfigManager.install_root}/#{package_name}"
        s = package_name.upcase
        Dir.glob("#{dir}/**/bashrc").each do |bashrc_file|
          PACKMAN.replace bashrc_file, {
            /\w+_INCLUDE\b/ => "PACKMAN_#{s}_INCLUDE",
            /\w+_LIBRARY\b/ => "PACKMAN_#{s}_LIBRARY",
            /\w+_RPATH\b/ => "PACKMAN_#{s}_RPATH"
          }, :not_exit
        end
      end
    end
  end
end
