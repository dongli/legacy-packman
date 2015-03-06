module PACKMAN
  class CompilerManager
    def self.delegated_methods
      [:compiler_info, :compiler_vendor, :compiler_version, :compiler_command,
       :compiler_flags_env_name, :default_compiler_flags, :append_customized_flags,
       :use_openmp, :compiler_support_openmp?, :all_compiler_support_openmp?,
       :use_mpi, :check_compiler, :compiler_flag]
    end

    def self.compiler_flags_env_name language
      case language
      when 'c'
        'CFLAGS'
      when 'c++'
        'CXXFLAGS'
      when 'fortran'
        'FCFLAGS'
      else
        PACKMAN.report_error "Unknown language #{PACKMAN.red language} for get environment variable name of compiler flags!"
      end
    end

    def self.init
      @@compiler_spec_classes = []
      PACKMAN.constants.each do |c|
        @@compiler_spec_classes << c if c.to_s =~ /\wCompilerSpec/
      end
      @@compiler_sets = []
      @@active_compiler_set = nil
    end

    def self.compiler_sets
      @@compiler_sets
    end

    def self.active_compiler_set
      @@active_compiler_set
    end

    def self.active_compiler_set_index
      @@compiler_sets.index @@active_compiler_set
    end

    def self.compiler_spec language, compiler_command
      # Only invoked by compiler set object.
      @@compiler_spec_classes.each do |compiler_spec_class|
        spec = eval "#{compiler_spec_class}.new" # Temporary variable.
        if spec.compiler_commands[language] =~ /\b#{compiler_command}\b/ or
           compiler_command =~ /\b#{spec.compiler_commands[language]}\b/
          spec.activate_compiler language, compiler_command
          return spec.clone
        end
      end
      CLI.report_error "Unknown compiler command #{CLI.red compiler_command} for language #{CLI.red language}!"
    end

    def self.set_compiler_sets command_hash_array
      @@compiler_sets = []
      command_hash_array.each do |command_hash|
        @@compiler_sets << CompilerSet.new(command_hash)
      end
    end

    def self.activate_compiler_set compiler_set_object_or_index
      if compiler_set_object_or_index.class == CompilerSet
        object = compiler_set_object_or_index
        if not @@compiler_sets.include? object
          CLI.report_error "Compiler set object #{CLI.red object} is not defined in compiler manager!"
        end
        @@active_compiler_set = object
      elsif compiler_set_object_or_index.class == Fixnum
        index = compiler_set_object_or_index
        if index < 0 or index >= compiler_sets.size
          CLI.report_error "Compiler set index #{CLI.red index} is not in range!"
        end
        @@active_compiler_set = @@compiler_sets[index]
      else
        CLI.report_error "Invalid argument #{CLI.red compiler_set_object_or_index}! "+
          "A compiler set object or index is expected."
      end
    end

    def self.compiler_info language
      if not @@active_compiler_set
        CLI.report_error "No compiler set is activated yet!"
      end
      if not @@active_compiler_set.info.has_key? language
        CLI.report_error "Active compiler set #{CLI.green active_compiler_set_index} "+
          "does not have a compiler for #{CLI.red language}!"
      end
      @@active_compiler_set.info[language]
    end

    def self.compiler_command language
      if @@active_compiler_set.info.has_key? language
        @@active_compiler_set.info[language][:command]
      end
    end

    def self.default_compiler_flags language
      info = compiler_info language
      info[:spec].default_flags[language]
    end

    def self.append_customized_flags flags, language = nil
      if not language
        @@active_compiler_set.info.each_key do |language|
          next if language == :installed_by_packman
          append_customized_flags flags, language
        end
      else
        flags = @@active_compiler_set.info[language][:spec].flags[flags] if flags.class == Symbol
        PACKMAN.append_env PACKMAN.compiler_flags_env_name(language), flags
      end
    end

    def self.check_compiler language, options = []
      options = [options] if not options.class == Array
      if not @@active_compiler_set.info[language]
        if options.include? :not_exit
          return false
        else
          CLI.report_error "#{CLI.red language.capitalize} compiler is not specified in compiler set!"
        end
      end
      compiler_command = @@active_compiler_set.info[language][:command]
      if not PACKMAN.does_command_exist? compiler_command
        if options.include? :not_exit
          return false
        else
          CLI.report_error "Compiler #{CLI.red compiler_command} for #{CLI.red language} does not exist!"
        end
      end
      return true
    end

    def self.compiler_vendor language
      @@active_compiler_set.info[language][:spec].vendor
    end

    def self.compiler_version language
      @@active_compiler_set.info[language][:spec].version
    end

    def self.compiler_flag language, flag
      if not @@active_compiler_set.info[language][:spec].flags.has_key? flag
        CLI.report_error "Compiler #{compiler_vendor language} does not provide flag #{CLI.red flag}! #{PACKMAN.contact_developer}"
      end
      @@active_compiler_set.info[language][:spec].flags[flag]
    end

    def self.use_openmp language = nil
      append_customized_flags :openmp, language
    end

    def self.compiler_support_openmp? language
      @@active_compiler_set.info[language][:spec].flags.has_key? :openmp
    end

    def self.all_compiler_support_openmp?
      @@active_compiler_set.info.each do |language, info|
        next if language == :installed_by_packman
        if not info[:spec].flags.has_key? :openmp
          return false
        end
      end
      if compiler_vendor('c') == 'gnu' and compiler_version('c') >= '4.9' and
         compiler_vendor('fortran') == 'intel' and compiler_version('fortran') <= '14.0.3'
        return false
      end
      return true
    end

    def self.use_mpi mpi_vendor = nil
      if mpi_vendor
        mpi = Package.instance mpi_vendor.to_s.capitalize
        # Check if the MPI library is installed by PACKMAN or not.
        if not PACKMAN.is_package_installed? mpi
          PACKMAN.report_error "MPI #{PACKMAN.red mpi_vendor} has not been installed!"
        end
        # Override the CC, CXX, F77, FC if they are set.
        PACKMAN.reset_env('CC', "#{mpi.bin}/#{mpi.provided_stuffs['c']}")
        PACKMAN.reset_env('MPICC', "#{mpi.bin}/#{mpi.provided_stuffs['c']}")
        PACKMAN.reset_env('CXX', "#{mpi.bin}/#{mpi.provided_stuffs['c++']}")
        PACKMAN.reset_env('MPICXX', "#{mpi.bin}/#{mpi.provided_stuffs['c++']}")
        PACKMAN.reset_env('F77', "#{mpi.bin}/#{mpi.provided_stuffs['fortran:77']}") if PACKMAN.compiler_command 'fortran'
        PACKMAN.reset_env('MPIF77', "#{mpi.bin}/#{mpi.provided_stuffs['fortran:77']}") if PACKMAN.compiler_command 'fortran'
        PACKMAN.reset_env('FC', "#{mpi.bin}/#{mpi.provided_stuffs['fortran:90']}") if PACKMAN.compiler_command 'fortran'
        PACKMAN.reset_env('MPIF90', "#{mpi.bin}/#{mpi.provided_stuffs['fortran:90']}") if PACKMAN.compiler_command 'fortran'
      else
        PACKMAN.reset_env('CC', "#{compiler_info('c')[:mpi_wrapper]}")
        PACKMAN.reset_env('MPICC', "#{compiler_info('c')[:mpi_wrapper]}")
        PACKMAN.reset_env('CXX', "#{compiler_info('c++')[:mpi_wrapper]}")
        PACKMAN.reset_env('MPICXX', "#{compiler_info('c++')[:mpi_wrapper]}")
        PACKMAN.reset_env('F77', "#{compiler_info('fortran')[:mpi_wrapper]}") if PACKMAN.compiler_command 'fortran'
        PACKMAN.reset_env('MPIF77', "#{compiler_info('fortran')[:mpi_wrapper]}") if PACKMAN.compiler_command 'fortran'
        PACKMAN.reset_env('FC', "#{compiler_info('fortran')[:mpi_wrapper]}") if PACKMAN.compiler_command 'fortran'
        PACKMAN.reset_env('MPIF90', "#{compiler_info('fortran')[:mpi_wrapper]}") if PACKMAN.compiler_command 'fortran'
      end
    end
  end
end
