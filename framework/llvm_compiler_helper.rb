module PACKMAN
  class LlvmCompilerHelper < CompilerHelper
    vendor 'llvm'
    default_flags '-O2'
    compiler_commands({ 'c' => 'clang', 'c++' => 'clang++', 'fortran' => nil })
    version_pattern /\d+\.\d+/
  end
end
