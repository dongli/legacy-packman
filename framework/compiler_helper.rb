module PACKMAN
  class CompilerHelper
    def self.init
      @@helpers = []
      PACKMAN.constants.each do |c|
        if c.to_s =~ /\wCompilerHelper/
          @@helpers.push eval("#{c}.new")
        end
      end
    end

    def self.helpers
      @@helpers
    end

    def self.vendor val
      self.class_eval "def vendor; '#{val}'; end"
    end

    def self.default_flags(val)
      self.class_eval "def default_flags; '#{val}'; end"
    end

    def self.compiler_commands(val)
      if not val.class == Hash
        PACKMAN::CLI.report_error "Argument should be a Hash object!"
      end
      self.class_eval "def compiler_commands; #{val}; end"
    end

    def self.version_pattern val
      self.class_eval "def version_pattern; '#{val}'; end"
    end

    def compiler_command language
      if not compiler_commands.has_key? language.to_s
        PACKMAN::CLI.report_error "#{vendor} does not provide a compiler for language #{PACKMAN::CLI.red language}!"
      end
      compiler_commands[language.to_s]
    end

    def version
      ['c', 'c++', 'fortran'].each do |language|
        begin
          cmd = compiler_command language
          PACKMAN.check_command cmd
          res = `#{cmd} -v 2>&1`
          return res.match(version_pattern)[0]
        rescue
          nil
        end
      end
    end
  end

  def self.compiler_helper vendor
    CompilerHelper.helpers.each do |helper|
      if helper.vendor == vendor
        return helper
      end
    end
    PACKMAN::CLI.report_error "Unknown compiler vendor #{PACKMAN::CLI.red vendor}!"
  end

  def self.compiler_vendor language, compiler
    CompilerHelper.helpers.each do |helper|
      if helper.compiler_command(language) == compiler
        return helper.vendor
      end
    end
  end

  def self.compiler_command language
    Package.compiler_set[language]
  end

  def self.default_flags language, compiler
    CompilerHelper.helpers.each do |helper|
      if compiler.to_s.include? helper.compiler_command(language)
        return helper.default_flags
      end
    end
  end

  def self.expand_packman_compiler_sets
    for i in 0..ConfigManager.compiler_sets.size-1
      if ConfigManager.compiler_sets[i].keys.include? 'installed_by_packman'
        compiler_name = ConfigManager.compiler_sets[i]['installed_by_packman'].capitalize
        ConfigManager.compiler_sets[i]['installed_by_packman'] = compiler_name
        if not PACKMAN::Package.defined? compiler_name
          PACKMAN::CLI.report_error "Unknown PACKMAN installed compiler \"#{compiler_name}\"!"
        end
        compiler_package = PACKMAN::Package.instance compiler_name
        compiler_package.provided_stuffs.each do |language, compiler|
          if ['c', 'c++', 'fortran'].include? language
            # User can overwrite the compiler.
            if not ConfigManager.compiler_sets[i].has_key? language
              ConfigManager.compiler_sets[i][language] = compiler
            end
          end
        end
      end
    end
  end

  def self.use_mpi mpi_vendor
    if not mpi_vendor
      CLI.report_error 'MPI library vendor should be provided!'
    end
    compiler_set_index = ConfigManager.compiler_sets.index Package.compiler_set
    # Check if the MPI library is installed by PACKMAN or not.
    if File.directory? "#{ConfigManager.install_root}/#{mpi_vendor}"
      mpi = Package.instance mpi_vendor.to_s.capitalize
      prefix = Package.prefix mpi
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
      CLI.under_construction!
    end
  end
end
