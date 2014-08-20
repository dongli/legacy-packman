module PACKMAN
  def self.install_packages
    # Reorganize the compiler set.
    tmp_compiler_sets = ConfigManager.compiler_sets
    for i in 0..ConfigManager.compiler_sets.size-1
      set = ConfigManager.compiler_sets[i]
      tmp_compiler_sets[i] = {}
      if set =~ /^package_.*/
        # Use the compiler installed by PACKMAN.
        case set
        when 'package_gcc'
          tmp_compiler_sets[i][:c] = :"#{Package.prefix(Gcc)}/bin/gcc"
          tmp_compiler_sets[i][:'c++'] = :"#{Package.prefix(Gcc)}/bin/g++"
          tmp_compiler_sets[i][:fortran] = :"#{Package.prefix(Gcc)}/bin/gfortran"
          # Label this compiler set.
          tmp_compiler_sets[i][:installed_by_packman] = 'Gcc'
        else
          PACKMAN.report_error "Unknown compiler \"#{set}\"!"
        end
      else
        set.split(/\s*\|\s*/).each do |c|
          language = c.split(/\s*:\s*/)[0]
          compiler = c.split(/\s*:\s*/)[1]
          if not language or not compiler
            PACKMAN.report_error "Bad compiler set format \"#{set}\"!"
          end
          tmp_compiler_sets[i][language.to_sym] = compiler.to_sym
        end
      end
    end
    ConfigManager.compiler_sets = tmp_compiler_sets
    # Install packages.
    ConfigManager.packages.each do |key, value|
      package_name = key.to_s.gsub(/^package_/, '').capitalize
      if not PACKMAN.class_defined?(package_name)
        PACKMAN.report_warning "Unknown package #{Tty.red}#{package_name}#{Tty.reset}!"
        next
      end
      report_notice "Install package #{package_name}."
      # Parameters need to be set:
      compiler_set_indices = nil
      value.split(/\s*\|\s*/).each do |spec|
        if spec =~ /^compiler_set:/
          tmp = spec.split(/\s*:\s*/)[1]
          begin
            compiler_set_indices = eval "#{tmp}"
          rescue
            PACKMAN.report_error "Bad compiler sets format \"#{spec}\" in package \"#{package_name}\"!"
          end
          if compiler_set_indices.class == Fixnum
            compiler_set_indices = [compiler_set_indices]
          end
          # Validate compiler_set_indices.
          compiler_set_indices.each do |index|
            if index.class != Fixnum
              PACKMAN.report_error "Bad compiler sets format \"#{spec}\" in package \"#{package_name}\"!"
            elsif index >= ConfigManager.compiler_sets.size
              PACKMAN.report_error "Compiler set index is out of range in package \"#{package_name}\"!"
            end
          end
        end
      end
      if not compiler_set_indices
        PACKMAN.report_error "Compiler set indices are not specified for package \"#{package_name}\"!"
      end
      package = eval "#{package_name}.new"
      # Check which compiler set is to use.
      compiler_sets = []
      for i in 0..ConfigManager.compiler_sets.size-1
        if compiler_set_indices.include?(i)
          compiler_sets.push ConfigManager.compiler_sets[i]
        end
        Package.install(compiler_sets, package)
      end
    end
  end
end
