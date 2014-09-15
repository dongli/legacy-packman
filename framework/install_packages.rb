module PACKMAN
  def self.install_packages
    expand_packman_compiler_sets
    # Report compilers and their flags.
    ConfigManager.compiler_sets.each do |compiler_set|
      report_notice "Compiler set #{compiler_set}"
      compiler_set.each do |language, compiler|
        next if language == 'installed_by_packman'
        report_notice "Default flags for #{Tty.blue}#{compiler}#{Tty.reset}: #{default_flags language, compiler}."
      end
    end
    # Install packages.
    ConfigManager.packages.each do |package_name, install_spec|
      if not PACKMAN::Package.defined? package_name
        PACKMAN.report_warning "Unknown package #{Tty.red}#{package_name}#{Tty.reset}!"
        next
      end
      # Parameters need to be set:
      if install_spec['use_binary']
        PACKMAN.report_notice "Use precompiled binary files for #{PACKMAN::Tty.green}#{package_name}#{PACKMAN::Tty.reset}."
      elsif not install_spec.has_key? 'compiler_set'
        PACKMAN.report_error "Compiler set indices are not specified for package \"#{package_name}\"!"
      end
      if not install_spec['use_binary']
        install_spec.each do |key, value|
          case key
          when 'compiler_set'
            install_spec['compiler_set'].each do |index|
              if index.class != Fixnum
                PACKMAN.report_error "Bad compiler sets format \"#{value}\" in package \"#{package_name}\"!"
              elsif index < 0 or index >= ConfigManager.compiler_sets.size
                PACKMAN.report_error "Compiler set index is out of range in package \"#{package_name}\"!"
              end
            end
          end
        end
      end
      package = PACKMAN::Package.instance package_name, install_spec
      # Check if the package building is finished.
      if package.has_label? 'under_construction'
        PACKMAN.report_warning "Sorry, #{PACKMAN::Tty.red}#{package.class}#{PACKMAN::Tty.reset} is still under construction!"
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
