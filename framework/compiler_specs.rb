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
end
