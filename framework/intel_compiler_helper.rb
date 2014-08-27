module PACKMAN
  class IntelCompilerHelper < CompilerHelper
    vendor 'intel'
    default_flags '-O3 -ip -fpic'
    compiler_commands({ 'c' => 'icc', 'c++' => 'icpc', 'fortran' => 'ifort' })
    version_pattern /\d+\.\d+(\.\d+)?/
  end
end
