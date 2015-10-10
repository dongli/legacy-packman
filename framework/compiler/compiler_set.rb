module PACKMAN
  class CompilerSet
    attr_reader :compilers

    def installed_by_packman?
      @installed_by_packman ||= false
    end

    def package_name
      if installed_by_packman?
        @package_name.to_sym
      else
        PACKMAN.report_error "Package set is not installed by PACKMAN!"
      end
    end

    def initialize command_hash
      # Expand compiler commands for the compiler installed by packman.
      if command_hash.has_key? :installed_by_packman
        compiler_name = command_hash[:installed_by_packman].capitalize
        if not Package.defined? compiler_name
          CLI.report_error "Unknown PACKMAN installed compiler #{CLI.red compiler_name}!"
        end
        compiler_package = Package.instance compiler_name
        prefix = PACKMAN.prefix compiler_package
        compiler_package.provided_stuffs.each do |language, compiler|
          if [:c, :cxx, :fortran].include? language
            # User can overwrite the compiler.
            if not command_hash.has_key? language
               command_hash[language] = "#{prefix}/bin/#{compiler}"
            end
          end
        end
      end
      # Set the specification for the compilers of each language (they may come
      # from different vendors).
      @compilers = {}
      command_hash.each do |language, compiler_command|
        if language == :installed_by_packman
          @installed_by_packman = true
          @package_name = compiler_command
          PACKMAN.load_package @package_name
          next
        end
        if language.to_s =~ /^mpi_(c|c\+\+|fortran)/
          # Let users choose the MPI wrapper.
          actual_language = language.to_s.gsub('mpi_', '').to_sym
          @compilers[actual_language] ||= {}
          if not PACKMAN.does_command_exist? compiler_command
            PACKMAN.report_error "MPI wrapper #{PACKMAN.red compiler_command} does not exist!"
          end
          @compilers[actual_language].mpi_wrapper = `which #{compiler_command}`.chomp
        else
          if not PACKMAN.does_command_exist? compiler_command
            PACKMAN.report_warning "Compiler command #{PACKMAN.red compiler_command} does not exist!"
            @compilers[language] = nil
          else
            @compilers[language] = CompilerManager.compiler_spec language, `which #{compiler_command}`.chomp
          end
        end
      end
    end

    def to_hash
      hash = {}
      hash[:c] = compilers[:c].to_hash if compilers.has_key? :c
      hash[:cxx] = compilers[:cxx].to_hash if compilers.has_key? :cxx
      hash[:fortran] = compilers[:fortran].to_hash if compilers.has_key? :fortran
      return hash
    end
  end
end
