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
    ConfigManager.packages.each do |package_name, package_spec|
      if not PACKMAN.class_defined? package_name
        PACKMAN.report_warning "Unknown package #{Tty.red}#{package_name}#{Tty.reset}!"
        next
      end
      # Parameters need to be set:
      if not package_spec.keys.include? 'compiler_set'
        PACKMAN.report_error "Compiler set indices are not specified for package \"#{package_name}\"!"
      end
      package_spec.each do |key, value|
        case key
        when 'compiler_set'
          package_spec['compiler_set'] = [value] if value.class == Fixnum
          package_spec['compiler_set'].each do |index|
            if index.class != Fixnum
              PACKMAN.report_error "Bad compiler sets format \"#{value}\" in package \"#{package_name}\"!"
            elsif index < 0 or index >= ConfigManager.compiler_sets.size
              PACKMAN.report_error "Compiler set index is out of range in package \"#{package_name}\"!"
            end
          end
        else
          PACKMAN.report_error "Unknown spec \"#{key} => #{value}\"!"
        end
      end
      package = eval "#{package_name}.new"
      # Check which compiler sets are to use.
      compiler_sets = []
      for i in 0..ConfigManager.compiler_sets.size-1
        if package_spec['compiler_set'].include?(i)
          compiler_sets.push ConfigManager.compiler_sets[i]
        end
      end
      Package.install(compiler_sets, package)
    end
  end
end
