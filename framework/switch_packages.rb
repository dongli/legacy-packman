module PACKMAN
  def self.switch_packages
    expand_packman_compiler_sets
    compiler_set = ConfigManager.compiler_sets[ConfigManager.defaults['compiler_set']]
    open("#{ConfigManager.install_root}/bashrc", 'w') do |file|
      # Check if the active compiler is installed by PACKMAN.
      if compiler_set.has_key?('installed_by_packman')
        file << "source #{Package.prefix(compiler_set['installed_by_packman'])}/bashrc\n"
      end
      Dir.foreach(ConfigManager.install_root) do |dir|
        next if dir =~ /^\.{1,2}$/
        dir = "#{ConfigManager.install_root}/#{dir}"
        next if not File.directory? dir
        bashrc_files = []
        Dir.foreach(dir) do |subdir|
          next if subdir =~ /^\.{1,2}$/
          subdir = "#{dir}/#{subdir}"
          next if not File.directory? subdir
          if File.exist? "#{subdir}/bashrc"
            # The package is compiler insensitive.
            bashrc_files << "source #{subdir}/bashrc\n"
          elsif File.exist? "#{subdir}/#{ConfigManager.defaults['compiler_set']}/bashrc"
            package_name = File.basename dir
            if ['mpich', 'openmpi'].include? package_name
              next if ConfigManager.defaults['mpi'] != package_name
            end
            # The package is built by the active compiler set.
            bashrc_files << "source #{subdir}/#{ConfigManager.defaults['compiler_set']}/bashrc\n"
          end
        end
        if bashrc_files.size == 1
          file << bashrc_files.first
        elsif bashrc_files.size > 1
          available_versions = bashrc_files.map { |p| File.basename(File.dirname(p)) }
          package_name = File.basename(dir).capitalize.to_sym
          if not ConfigManager.packages.has_key? package_name or
            not ConfigManager.packages[package_name].has_key? 'version'
            PACKMAN::CLI.report_error "Package #{CLI.red package_name} has multiple versions "+
              "(#{available_versions.join(', ')}), you should choose one in #{CommandLine.config_file}!"
          end
          bashrc_files.each do |f|
            if f =~ /#{ConfigManager.packages[package_name]['version']}/
              file << f
              break
            end
          end
        end
      end
    end
    PACKMAN::CLI.report_notice "Add \"source #{ConfigManager.install_root}/bashrc\" to your BASH configuation file if it is not there."
    PACKMAN::CLI.report_notice "You need to login again to make the changes effective."
  end
end
