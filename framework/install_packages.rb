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
      # Parameters need to be set:
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
      # Check if the package building is finished.
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
      Package.install(compiler_sets, package)
    end
  end
end
