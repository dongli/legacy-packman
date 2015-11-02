module PACKMAN
  class CompilerManager
    def self.delegated_methods
      [:compiler, :has_compiler?, :cppflags, :ldflags,
       :compiler_flags_env_name, :append_customized_flags,
       :use_openmp, :compiler_support_openmp?, :all_compiler_support_openmp?,
       :use_mpi, :compiler_has_mpi_wrapper?, :active_compiler_set]
    end

    def self.compiler_flags_env_name language
      case language
      when :c
        'CFLAGS'
      when :cxx
        'CXXFLAGS'
      when :fortran
        'FCFLAGS'
      else
        PACKMAN.report_error "Unknown language #{PACKMAN.red language} for get environment variable name of compiler flags!"
      end
    end

    def self.init
      @@compiler_spec_classes = []
      PACKMAN.constants.each do |c|
        @@compiler_spec_classes << c if c.to_s =~ /\wCompiler/
      end
      @@compiler_sets = []
      @@active_compiler_set = nil
    end

    def self.compiler_sets
      @@compiler_sets
    end

    def self.add_compiler_set command_hash
      @@compiler_sets ||= []
      @@compiler_sets << CompilerSet.new(command_hash)
    end

    def self.active_compiler_set
      @@active_compiler_set
    end

    def self.active_compiler_set_index
      @@compiler_sets.index @@active_compiler_set
    end

    def self.compiler_spec language, command
      language = language.to_sym
      # Only invoked by compiler set object.
      @@compiler_spec_classes.each do |compiler_spec_class|
        spec = eval "#{compiler_spec_class}.new" # Temporary variable.
        next if not spec.all_commands[language]
        if spec.all_commands[language] =~ /\b#{command}\b/ or
           command =~ /\b#{spec.all_commands[language]}\b/
          spec.activate_compiler language, command
          return spec.clone
        end
      end
      CLI.report_error "Unknown compiler command #{CLI.red command} for language #{CLI.red language}!"
    end

    def self.set_compiler_sets command_hash_array
      @@compiler_sets = []
      command_hash_array.each do |command_hash|
        @@compiler_sets << CompilerSet.new(command_hash)
      end
    end

    def self.activate_default_compiler_set
      activate_compiler_set ConfigManager.defaults[:compiler_set_index]
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
      elsif compiler_set_object_or_index.class == String
        activate_compiler_set compiler_set_object_or_index.to_i
      else
        CLI.report_error "Invalid argument #{CLI.red compiler_set_object_or_index}! "+
          "A compiler set object or index is expected."
      end
    end

    def self.compiler language
      if not @@active_compiler_set
        CLI.report_error "No compiler set is activated yet!"
      end
      if not @@active_compiler_set.compilers.has_key? language
        CLI.report_error "Active compiler set #{CLI.green active_compiler_set_index} "+
          "does not have a compiler for #{CLI.red language}!"
      end
      @@active_compiler_set.compilers[language]
    end

    def self.compiler_has_mpi_wrapper? language
      @@active_compiler_set.compilers[language].mpi_wrapper != nil
    end

    def self.append_customized_flags flags, language = nil
      if not language
        @@active_compiler_set.compilers.each_key do |language|
          append_customized_flags flags, language
        end
      else
        flags = @@active_compiler_set.compilers[language].flags[flags] if flags.class == Symbol
        PACKMAN.append_env PACKMAN.compiler_flags_env_name(language), flags
      end
    end

    def self.has_compiler? language, options = []
      options = [options] if not options.class == Array
      if not @@active_compiler_set.compilers[language]
        if options.include? :not_exit
          return false
        else
          CLI.report_error "#{CLI.red language.capitalize} compiler is not specified in compiler set!"
        end
      end
      compiler_command = @@active_compiler_set.compilers[language].command
      if not PACKMAN.does_command_exist? compiler_command
        if options.include? :not_exit
          return false
        else
          CLI.report_error "Compiler #{CLI.red compiler_command} for #{CLI.red language} does not exist!"
        end
      end
      return true
    end

    def self.has_packman_gcc?
      @@compiler_sets.each do |compiler_set|
        return true if compiler_set.installed_by_packman?
      end
      false
    end

    def self.use_openmp language = nil
      append_customized_flags :openmp, language
    end

    def self.compiler_support_openmp? language
      @@active_compiler_set.compilers[language].flags.has_key? :openmp
    end

    def self.all_compiler_support_openmp?
      @@active_compiler_set.compilers.each do |language, compiler|
        if not compiler.flags.has_key? :openmp
          return false
        end
      end
      # TODO: Clean the following codes.
      if compiler(:c).vendor == :gnu and compiler(:c).version >= '4.9' and
         compiler(:fortran).vendor == :intel and compiler(:fortran).version <= '14.0.3'
        return false
      end
      return true
    end

    def self.use_mpi mpi_vendor = nil
      mpi = Package.instance mpi_vendor.to_s.capitalize
      if compiler(:c).mpi_wrapper
        PACKMAN.reset_env('CC', "#{compiler(:c).mpi_wrapper}")
        PACKMAN.reset_env('MPICC', "#{compiler(:c).mpi_wrapper}")
      else
        PACKMAN.reset_env('CC', "#{mpi.bin}/#{mpi.provided_stuffs[:c]}")
        PACKMAN.reset_env('MPICC', "#{mpi.bin}/#{mpi.provided_stuffs[:c]}")
      end
      if compiler(:cxx).mpi_wrapper
        PACKMAN.reset_env('CXX', "#{compiler(:cxx).mpi_wrapper}")
        PACKMAN.reset_env('MPICXX', "#{compiler(:cxx).mpi_wrapper}")
      else
        PACKMAN.reset_env('CXX', "#{mpi.bin}/#{mpi.provided_stuffs[:cxx]}")
        PACKMAN.reset_env('MPICXX', "#{mpi.bin}/#{mpi.provided_stuffs[:cxx]}")
      end
      if PACKMAN.compiler(:fortran).command
        if compiler(:fortran).mpi_wrapper
          PACKMAN.reset_env('F77', "#{compiler(:fortran).mpi_wrapper}")
          PACKMAN.reset_env('MPIF77', "#{compiler(:fortran).mpi_wrapper}")
          PACKMAN.reset_env('FC', "#{compiler(:fortran).mpi_wrapper}")
          PACKMAN.reset_env('MPIF90', "#{compiler(:fortran).mpi_wrapper}")
        else
          PACKMAN.reset_env('F77', "#{mpi.bin}/#{mpi.provided_stuffs[:fortran]['77']}")
          PACKMAN.reset_env('MPIF77', "#{mpi.bin}/#{mpi.provided_stuffs[:fortran]['77']}")
          PACKMAN.reset_env('FC', "#{mpi.bin}/#{mpi.provided_stuffs[:fortran]['90']}")
          PACKMAN.reset_env('MPIF90', "#{mpi.bin}/#{mpi.provided_stuffs[:fortran]['90']}")
        end
      end
    end

    def self.cppflags
      "-I#{ConfigManager.install_root}/#{active_compiler_set_index}/include"
    end

    def self.ldflags
      "-L#{ConfigManager.install_root}/#{active_compiler_set_index}/lib"
    end
  end
end
