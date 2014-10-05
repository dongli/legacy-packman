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
        if g.compiler_commands[language] =~ /\b#{compiler}\b/ or
           compiler =~ /\b#{g.compiler_commands[language]}\b/
          return g.vendor
        end
      end
      PACKMAN::CLI.report_error "Unknown compiler command #{PACKMAN::CLI.red compiler} for language #{PACKMAN::CLI.red language}!"
    end

    def self.default_flags language, compiler
      @@compiler_groups.each do |g|
        if g.compiler_commands.has_key? language and
          (g.compiler_commands[language] =~ /\b#{compiler}\b/ or
           compiler =~ /\b#{g.compiler_commands[language]}\b/)
          return g.default_flags[language]
        end
      end
    end

    def self.customized_flags language, compiler
      @@compiler_groups.each do |g|
        if g.compiler_commands.has_key? language and
          (compiler.include? g.compiler_commands[language] or
           g.compiler_commands[language].include? compiler)
          return g.customized_flags[language]
        end
      end
    end

    def self.append_customized_flags language, flags
      if language == :all
        Package.compiler_set.each_key do |language|
          next if language == 'installed_by_packman'
          append_customized_flags language, flags
        end
      else
        compiler = Package.compiler_set[language]
        vendor = CompilerManager.compiler_vendor language, compiler
        group = CompilerManager.compiler_group vendor
        if flags.class == Symbol
          group.append_customized_flags language, group.flags[flags]
        else
          group.append_customized_flags language, flags
        end
      end
    end

    def self.clean_customized_flags language = nil
      if language
        compiler = Package.compiler_set[language]
        vendor = CompilerManager.compiler_vendor language, compiler
        group = CompilerManager.compiler_group vendor
        group.clean_customized_flags language
      else
        Package.compiler_set.each_key do |language|
          next if language == 'installed_by_packman'
          clean_customized_flags language
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
          prefix = PACKMAN::Package.prefix compiler_package
          compiler_package.provided_stuffs.each do |language, compiler|
            if ['c', 'c++', 'fortran'].include? language
              # User can overwrite the compiler.
              if not PACKMAN::ConfigManager.compiler_sets[i].has_key? language
                PACKMAN::ConfigManager.compiler_sets[i][language] = "#{prefix}/bin/#{compiler}"
              end
            end
          end
        end
      end
    end

    def self.use_openmp language = :all
      append_customized_flags language, :openmp
    end

    def self.use_mpi mpi_vendor
      compiler_set_index = PACKMAN::ConfigManager.compiler_sets.index PACKMAN::Package.compiler_set
      # Check if the MPI library is installed by PACKMAN or not.
      if File.directory? "#{PACKMAN::ConfigManager.install_root}/#{mpi_vendor}"
        mpi = PACKMAN::Package.instance mpi_vendor.to_s.capitalize
        prefix = PACKMAN::Package.prefix mpi
        # Override the CC, CXX, F77, FC if they are set.
        PACKMAN.change_env "CC=#{prefix}/bin/#{mpi.provided_stuffs['c']}"
        PACKMAN.change_env "MPICC=#{prefix}/bin/#{mpi.provided_stuffs['c']}"
        PACKMAN.change_env "CXX=#{prefix}/bin/#{mpi.provided_stuffs['c++']}"
        PACKMAN.change_env "MPICXX=#{prefix}/bin/#{mpi.provided_stuffs['c++']}"
        PACKMAN.change_env "F77=#{prefix}/bin/#{mpi.provided_stuffs['fortran:77']}"
        PACKMAN.change_env "MPIF77=#{prefix}/bin/#{mpi.provided_stuffs['fortran:77']}"
        PACKMAN.change_env "FC=#{prefix}/bin/#{mpi.provided_stuffs['fortran:90']}"
        PACKMAN.change_env "MPIF90=#{prefix}/bin/#{mpi.provided_stuffs['fortran:90']}"
      else
        PACKMAN::CLI.report_error "Can not find #{PACKMAN::CLI.red mpi_vendor} MPI library!"
      end
    end
  end

  def self.compiler_vendor language, compiler = nil
    compiler ||= Package.compiler_set[language]
    CompilerManager.compiler_vendor language, compiler
  end

  def self.compiler_command language
    Package.compiler_set[language]
  end

  def self.default_compiler_flags language, compiler = nil
    compiler ||= Package.compiler_set[language]
    CompilerManager.default_flags language, compiler
  end

  def self.customized_compiler_flags language, compiler = nil
    compiler ||= Package.compiler_set[language]
    CompilerManager.customized_flags language, compiler
  end

  def self.append_customized_flags language, flags
    CompilerManager.append_customized_flags language, flags
  end

  def self.use_openmp language = :all
    CompilerManager.use_openmp language
  end

  def self.use_mpi mpi_vendor
    CompilerManager.use_mpi mpi_vendor
  end

  def self.compiler_support_openmp? language, compiler = nil
    compiler ||= Package.compiler_set[language]
    vendor = CompilerManager.compiler_vendor language, compiler
    CompilerManager.compiler_group(vendor).flags.has_key? :openmp
  end
end
