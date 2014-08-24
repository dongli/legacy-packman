module PACKMAN
  def self.get_c_compiler
    Package.compiler_set['c']
  end

  def self.get_cxx_vendor
    cxx_compiler = Package.compiler_set['c++']
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
    Package.compiler_set['c++']
  end

  def self.get_cxx_version
    cxx_compiler = Package.compiler_set['c++']
    case get_cxx_vendor
    when :gcc
      res = `#{cxx_compiler} -v 2>&1`
      cxx_version = res.scan(/gcc version ([^ ]*)/).first.first
    when :intel

    when :llvm
    end
    return cxx_version
  end

  def self.expand_packman_compiler_sets
    for i in 0..ConfigManager.compiler_sets.size-1
      if ConfigManager.compiler_sets[i].keys.include? 'installed_by_packman'
        compiler_name = ConfigManager.compiler_sets[i]['installed_by_packman'].capitalize
        ConfigManager.compiler_sets[i]['installed_by_packman'] = compiler_name
        if not PACKMAN.class_defined? compiler_name
          PACKMAN.report_error "Unknown PACKMAN installed compiler \"#{compiler_name}\"!"
        end
        compiler_package = eval "#{compiler_name}.new"
        compiler_package.stuffs.each do |language, compiler|
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
end
