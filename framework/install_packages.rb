module PACKMAN
  def self.all_compiler_sets
    @@all_compiler_sets
  end

  def self.package_root
    @@package_root
  end

  def self.install_root
    @@install_root
  end

  def self.install_packages(config_manager)
    @@package_root = File.absolute_path(config_manager.get_value('packman', 'package_root'))
    @@install_root = File.absolute_path(config_manager.get_value('packman', 'install_root'))

    # Get compiler sets.
    @@all_compiler_sets = []
    config_manager.get_keys('packman').each do |key|
      if key =~ /^compiler_set_.*/
        tmp = config_manager.get_value('packman', key)
        @@all_compiler_sets.push Hash.new
        if tmp =~ /^package_.*/
          # Use the compiler installed by PACKMAN.
          case tmp
          when 'package_gcc'
            @@all_compiler_sets.last[:c] = :"#{Package.prefix(Gcc)}/bin/gcc"
            @@all_compiler_sets.last[:'c++'] = :"#{Package.prefix(Gcc)}/bin/g++"
            @@all_compiler_sets.last[:fortran] = :"#{Package.prefix(Gcc)}/bin/gfortran"
            # Label this compiler set.
            @@all_compiler_sets.last[:installed_by_packman] = 'Gcc'
          else
            PACKMAN.report_error "Unknown compiler \"#{tmp}\"!"
          end
        else
          tmp.split(/\s*\|\s*/).each do |c|
            language = c.split(/\s*:\s*/)[0]
            compiler = c.split(/\s*:\s*/)[1]
            if not language or not compiler
              PACKMAN.report_error "Bad compiler set format \"#{tmp}\"!"
            end
            @@all_compiler_sets.last[language.to_sym] = compiler.to_sym
          end
        end
      end
    end

    # Install packages.
    config_manager.get_keys('packman').each do |key|
      if key =~ /^package_.*/
        package_name = key.to_s.gsub(/^package_/, '').capitalize
        next if package_name == 'Root'
        if not PACKMAN.class_defined?(package_name)
          PACKMAN.report_warning "Unknown package #{Tty.red}#{package_name}#{Tty.reset}!"
          next
        end

        report_notice "Install package #{package_name}."
        # Parse installation specifications.
        specs = config_manager.get_value('packman', key)
        # Parameters need to be set:
        compiler_set_indices = nil
        specs.split(/\s*\|\s*/).each do |spec|
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
              elsif index >= @@all_compiler_sets.size
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
        for i in 0..@@all_compiler_sets.size-1
          if compiler_set_indices.include?(i)
            compiler_sets.push @@all_compiler_sets[i]
          end
        end
        Package.install(compiler_sets, package)
      end
    end
  end
end
