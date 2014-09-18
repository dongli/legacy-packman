module PACKMAN
  def self.switch_packages
    expand_packman_compiler_sets
    compiler_set = ConfigManager.compiler_sets[ConfigManager.active_compiler_set]
    open("#{ConfigManager.install_root}/bashrc", 'w') do |file|
      # Check if the active compiler is installed by PACKMAN.
      if compiler_set.has_key?('installed_by_packman')
        file << "source #{Package.prefix(compiler_set['installed_by_packman'])}/bashrc\n"
      end
      Dir.foreach(ConfigManager.install_root) do |dir|
        next if dir =~ /^\.{1,2}$/
        dir = "#{ConfigManager.install_root}/#{dir}"
        next if not File.directory? dir
        Dir.foreach(dir) do |subdir|
          next if subdir =~ /^\.{1,2}$/
          subdir = "#{dir}/#{subdir}"
          next if not File.directory? subdir
          if File.exist? "#{subdir}/bashrc"
            # The package is compiler insensitive.
            file << "source #{subdir}/bashrc\n"
          elsif File.exist? "#{subdir}/#{ConfigManager.active_compiler_set}/bashrc"
            # The package is built by the active compiler set.
            file << "source #{subdir}/#{ConfigManager.active_compiler_set}/bashrc\n"
          end
        end
      end
    end
    report_notice "Add \"source #{ConfigManager.install_root}/bashrc\" to your BASH configuation file if it is not there."
    report_notice "You need to login again to make the changes effective."
  end
end
