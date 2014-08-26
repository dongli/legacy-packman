module PACKMAN
  def self.switch_packages
    expand_packman_compiler_sets
    compiler_set = ConfigManager.compiler_sets[ConfigManager.active_compiler_set]
    open("#{ConfigManager.install_root}/bashrc", 'w') do |file|
      # Check if the active compiler is installed by PACKMAN.
      if compiler_set.has_key?('installed_by_packman')
        file << "source #{Package.prefix(compiler_set['installed_by_packman'])}/bashrc\n"
      end
      # Add other packages.
      Dir.glob("#{ConfigManager.install_root}/**/bashrc").each do |path|
        if path =~ /\/#{ConfigManager.active_compiler_set}\/bashrc/
          file << "source #{path}\n"
        end
      end
    end
    report_notice "Add \"source #{ConfigManager.install_root}/bashrc\" to your BASH configuation file if it is not there."
    report_notice "You need to login again to make the changes effective."
  end
end
