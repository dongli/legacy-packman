module PACKMAN
  class CompilerManager
    def self.delegated_methods
      [:compiler_info, :compiler_vendor, :compiler_command,
       :default_compiler_flags, :append_customized_flags,
       :clean_customized_flags, :customized_compiler_flags,
       :use_openmp, :compiler_support_openmp?, :use_mpi, :check_compiler]
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
          # Reset the compiler command.
          spec.compiler_commands[language] = compiler_command
          spec.activate_compiler language
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
        spec = @@active_compiler_set.info[language][:spec]
        if flags.class == Symbol
          spec.append_customized_flags spec.flags[flags], language
        else
          spec.append_customized_flags flags, language
        end
      end
    end

    def self.clean_customized_flags language = nil
      if not language
        @@active_compiler_set.info.each_key do |language|
          next if language == :installed_by_packman
          clean_customized_flags language
        end
      else
        spec = @@active_compiler_set.info[language][:spec]
        spec.clean_customized_flags language
      end
    end

    def self.customized_compiler_flags language
      spec = @@active_compiler_set.info[language][:spec]
      spec.customized_flags[language]
    end

    def self.check_compiler language
      compiler_command = @@active_compiler_set.info[language][:command]
      if not PACKMAN.does_command_exist? compiler_command
        CLI.report_error "Compiler #{CLI.red compiler_command} for #{CLI.red language} does not exist!"
      end
    end

    def self.compiler_vendor language
      @@active_compiler_set.info[language][:spec].vendor
    end

    def self.use_openmp language = nil
      append_customized_flags :openmp, language
    end

    def self.compiler_support_openmp? language
      @@active_compiler_set.info[language][:spec].flags.has_key? :openmp
    end

    def self.use_mpi mpi_vendor
      # Check if the MPI library is installed by PACKMAN or not.
      if File.directory? "#{ConfigManager.install_root}/#{mpi_vendor}"
        mpi = Package.instance mpi_vendor.to_s.capitalize
        prefix = PACKMAN.prefix mpi
        # Override the CC, CXX, F77, FC if they are set.
        PACKMAN.change_env "CC=#{prefix}/bin/#{mpi.provided_stuffs['c']}"
        PACKMAN.change_env "MPICC=#{prefix}/bin/#{mpi.provided_stuffs['c']}"
        PACKMAN.change_env "CXX=#{prefix}/bin/#{mpi.provided_stuffs['c++']}"
        PACKMAN.change_env "MPICXX=#{prefix}/bin/#{mpi.provided_stuffs['c++']}"
        PACKMAN.change_env "F77=#{prefix}/bin/#{mpi.provided_stuffs['fortran:77']}" if PACKMAN.compiler_command 'fortran'
        PACKMAN.change_env "MPIF77=#{prefix}/bin/#{mpi.provided_stuffs['fortran:77']}" if PACKMAN.compiler_command 'fortran'
        PACKMAN.change_env "FC=#{prefix}/bin/#{mpi.provided_stuffs['fortran:90']}" if PACKMAN.compiler_command 'fortran'
        PACKMAN.change_env "MPIF90=#{prefix}/bin/#{mpi.provided_stuffs['fortran:90']}" if PACKMAN.compiler_command 'fortran'
      else
        CLI.report_error "#{CLI.red mpi_vendor} MPI library is not installed by PACKMAN!"
      end
    end
  end
end
