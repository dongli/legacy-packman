module PACKMAN
  class GccCompilerHelper < CompilerHelper
    vendor 'gcc'
    default_flags '-O3'
    compiler_commands({ 'c' => 'gcc', 'c++' => 'g++', 'fortran' => 'gfortran' })
    version_pattern /\d+\.\d+\.\d+/
  end
end
