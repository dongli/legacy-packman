module PACKMAN
  class LlvmCompilerGroup < CompilerGroup
    vendor 'llvm'
    compiler_command 'c'       => ['clang',   '-O2']
    compiler_command 'c++'     => ['clang++', '-O2']
    compiler_command 'fortran' => [nil,       nil]
    version_pattern /\d+\.\d+/
  end
end