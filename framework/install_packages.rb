module PACKMAN
  def self.install_packages
    expand_packman_compiler_sets
    # Report compilers and their flags.
    for i in 0..ConfigManager.compiler_sets.size-1
      CLI.report_notice "Compiler set #{CLI.green i}:"
      ConfigManager.compiler_sets[i].each do |language, compiler|
        next if language == 'installed_by_packman'
        print "#{CLI.blue '==>'} #{language}: #{compiler} #{default_flags language, compiler}\n"
        # CLI.report_notice "Default flags for #{CLI.blue compiler}: #{default_flags language, compiler}."
      end
    end
    # Install packages.
    ConfigManager.packages.each do |package_name, install_spec|
      if not Package.defined? package_name
        CLI.report_warning "Unknown package #{CLI.red package_name}!"
        next
      end
      package = Package.instance package_name, install_spec
      # Check if the compiler_set option is set when necessary.
      if not install_spec['use_binary'] and
        not package.has_label? 'compiler_insensitive' and
        not install_spec.has_key? 'compiler_set'
        CLI.report_error "Compiler set indices are not specified for package \"#{package_name}\"!"
      end
      if not install_spec['use_binary']
        # When a package is labeled as 'compiler_insensitive', and no 'compiler_set' is specified, use the first one.
        if package.has_label? 'compiler_insensitive' and not install_spec.has_key? 'compiler_set'
          install_spec['compiler_set'] = [0]
        end
        install_spec.each do |key, value|
          case key
          when 'compiler_set'
            install_spec['compiler_set'].each do |index|
              if index.class != Fixnum
                CLI.report_error "Bad compiler sets format \"#{value}\" in package \"#{package_name}\"!"
              elsif index < 0 or index >= ConfigManager.compiler_sets.size
                CLI.report_error "Compiler set index is out of range in package \"#{package_name}\"!"
              end
            end
          end
        end
      end
      # Check if the package is still under construction.
      if package.has_label? 'under_construction'
        CLI.report_warning "Sorry, #{CLI.red package.class} is still under construction!"
        next
      end
      # Check which compiler sets are to use.
      compiler_sets = []
      if not install_spec['use_binary']
        for i in 0..ConfigManager.compiler_sets.size-1
          if install_spec['compiler_set'].include?(i)
            compiler_sets.push ConfigManager.compiler_sets[i]
          end
        end
      end
      install_package compiler_sets, package
    end
  end

  def self.install_package compiler_sets, package, options = []
    options = [options] if not options.class == Array
    # Check dependencies.
    package.dependencies.each do |depend|
      depend_package = Package.instance depend.capitalize
      install_package compiler_sets, depend_package, :depend
      if not depend_package.skip?
        RunManager.append_bashrc_path("#{Package.prefix(depend_package)}/bashrc")
      end
    end
    # Check if the package should be skipped.
    if package.skip?
      if not package.skip_distros.include? :all and not package.installed?
        CLI.report_error "Package #{PACKMAN::CLI.red package.class} "+
          "should be provided by system!\n#{PACKMAN::CLI.blue '==>'} "+
          "The possible installation method is:\n#{package.install_method}"
      end
      return
    end
    # Check if the package has been downloaded or not. If not, download it when
    # the OS is connected with internet.
    begin
      PACKMAN.download_package package
    rescue
      if not OS.connect_internet?
        CLI.report_error "#{CLI.red package_file} has not been downloaded!"
      end
    end
    # Install package.
    if compiler_sets.empty?
      # Install precompiled package.
      prefix = Package.prefix package, :compiler_insensitive
      # Check if the package has alreadly installed.
      bashrc = "#{prefix}/bashrc"
      if File.exist?(bashrc)
        f = File.new(bashrc, 'r')
        first_line = f.readline
        if first_line =~ /#{package.sha1}/
          if not options.include? :depend
            CLI.report_notice "Package #{PACKMAN::CLI.green package.class} has been installed."
          end
          return
        end
        f.close
      end
      # Use precompiled binary file.
      CLI.report_notice "Use precompiled binary files for #{CLI.green package.class}."
      PACKMAN.mkdir prefix, :force
      PACKMAN.cd prefix
      PACKMAN.decompress package_file
      PACKMAN.cd_back
      # Write bashrc file for the package.
      Package.bashrc package, :compiler_insensitive
      package.postfix
    else
      # Build package for each compiler set.
      compiler_sets.each do |compiler_set|
        Package.compiler_set = compiler_set
        # Check if the package has alreadly installed.
        bashrc = "#{Package.prefix(package)}/bashrc"
        if File.exist? bashrc
          f = File.new bashrc, 'r'
          first_line = f.readline
          if first_line =~ /#{package.sha1}/
            if not options.include? :depend
              PACKMAN::CLI.report_notice "Package #{PACKMAN::CLI.green package.class} has been installed."
            end
            next
          end
          f.close
        end
        # Decompress package file.
        if package.respond_to? :filename
          package.decompress_to ConfigManager.package_root
        elsif package.respond_to? :dirname
          package.copy_to ConfigManager.package_root
        end
        tmp = Dir.glob("#{ConfigManager.package_root}/#{package.class}/*")
        if tmp.size != 1 or not File.directory? tmp.first
          tmp = ["#{ConfigManager.package_root}/#{package.class}"]
        end
        build_dir = tmp.first
        PACKMAN.cd build_dir
        # Apply patches.
        Package.apply_patch package
        # Install package.
        PACKMAN::CLI.report_notice "Install package #{CLI.green package.class}."
        package.install
        PACKMAN.cd_back
        FileUtils.rm_rf build_dir
        # Write bashrc file for the package.
        Package.bashrc package
        package.postfix
      end
    end
    # Clean build files.
    if Dir.exist? "#{ConfigManager.package_root}/#{package.class}"
      FileUtils.rm_rf "#{ConfigManager.package_root}/#{package.class}"
    end
    # Clean the bashrc pathes.
    if not options.include? :depend
      RunManager.clean_bashrc_path
    end
  end
end
