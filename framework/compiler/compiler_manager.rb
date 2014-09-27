module PACKMAN
  class CompilerManager
    def self.init
      @@compiler_groups = []
      PACKMAN.constants.each do |c|
        if c.to_s =~ /\wCompilerGroup/
          @@compiler_groups.push eval("#{c}.new")
        end
      end
    end

    def self.compiler_group vendor
      @@compiler_groups.each do |g|
        if g.vendor == vendor
          return g
        end
      end
      PACKMAN::CLI.report_error "Unknown compiler vendor #{PACKMAN::CLI.red vendor}!"
    end

    def self.compiler_vendor language, compiler
      @@compiler_groups.each do |g|
        if g.compiler_commands[language] =~ /#{compiler}/
          return g.vendor
        end
      end
      PACKMAN::CLI.report_error "Unknown compiler command #{PACKMAN::CLI.red compiler} for language #{PACKMAN::CLI.red language}!"
    end

    def self.default_flags language, compiler
      @@compiler_groups.each do |g|
        if compiler.to_s.include? g.compiler_commands[language]
          return g.default_flags[language]
        end
      end
    end

    def self.expand_packman_compiler_sets
      for i in 0..ConfigManager.compiler_sets.size-1
        if PACKMAN::ConfigManager.compiler_sets[i].keys.include? 'installed_by_packman'
          compiler_name = PACKMAN::ConfigManager.compiler_sets[i]['installed_by_packman'].capitalize
          PACKMAN::ConfigManager.compiler_sets[i]['installed_by_packman'] = compiler_name
          if not PACKMAN::Package.defined? compiler_name
            PACKMAN::CLI.report_error "Unknown PACKMAN installed compiler \"#{compiler_name}\"!"
          end
          compiler_package = PACKMAN::Package.instance compiler_name
          compiler_package.provided_stuffs.each do |language, compiler|
            if ['c', 'c++', 'fortran'].include? language
              # User can overwrite the compiler.
              if not PACKMAN::ConfigManager.compiler_sets[i].has_key? language
                PACKMAN::ConfigManager.compiler_sets[i][language] = compiler
              end
            end
          end
        end
      end
    end

    def self.use_openmp language
      p PACKMAN::Package.compiler_set
    end

    def self.use_mpi mpi_vendor
      if not mpi_vendor
        PACKMAN::CLI.report_error 'MPI library vendor should be provided!'
      end
      compiler_set_index = PACKMAN::ConfigManager.compiler_sets.index PACKMAN::Package.compiler_set
      # Check if the MPI library is installed by PACKMAN or not.
      if File.directory? "#{PACKMAN::ConfigManager.install_root}/#{mpi_vendor}"
        mpi = PACKMAN::Package.instance mpi_vendor.to_s.capitalize
        prefix = PACKMAN::Package.prefix mpi
        # Override the CC, CXX, F77, FC if they are set.
        change_env "CC=#{prefix}/bin/#{mpi.provided_stuffs['c']}"
        change_env "MPICC=#{prefix}/bin/#{mpi.provided_stuffs['c']}"
        change_env "CXX=#{prefix}/bin/#{mpi.provided_stuffs['c++']}"
        change_env "MPICXX=#{prefix}/bin/#{mpi.provided_stuffs['c++']}"
        change_env "F77=#{prefix}/bin/#{mpi.provided_stuffs['fortran:77']}"
        change_env "MPIF77=#{prefix}/bin/#{mpi.provided_stuffs['fortran:77']}"
        change_env "FC=#{prefix}/bin/#{mpi.provided_stuffs['fortran:90']}"
        change_env "MPIF90=#{prefix}/bin/#{mpi.provided_stuffs['fortran:90']}"
      else
        PACKMAN::CLI.under_construction!
      end
    end
  end
end