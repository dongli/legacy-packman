module PACKMAN
  def self.get_cxx_vendor
    cxx_compiler = Package.compiler_set[:'c++']
    case cxx_compiler
    when /.*g++.*/
      return :gcc
    when /.*icpc.*/
      return :intel
    when /.*clang++.*/
      return :llvm
    else
      report_error "Unknown C++ compiler \"#{cxx_compiler}\"!"
    end
  end

  def self.get_cxx_compiler
    cxx_compiler = Package.compiler_set[:'c++']
  end

  def self.get_cxx_version
    cxx_compiler = Package.compiler_set[:'c++']
    case get_cxx_vendor
    when :gcc
      res = `#{cxx_compiler} -v 2>&1`
      cxx_version = res.scan(/gcc version ([^ ]*)/).first.first
    when :intel

    when :llvm
    end
    return cxx_version
  end

  def self.reorganize_compiler_sets
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
          report_error "Unknown compiler \"#{set}\"!"
        end
      else
        set.split(/\s*\|\s*/).each do |c|
          language = c.split(/\s*:\s*/)[0]
          compiler = c.split(/\s*:\s*/)[1]
          if not language or not compiler
            report_error "Bad compiler set format \"#{set}\"!"
          end
          tmp_compiler_sets[i][language.to_sym] = compiler.to_sym
        end
      end
    end
    ConfigManager.compiler_sets = tmp_compiler_sets
  end
end
