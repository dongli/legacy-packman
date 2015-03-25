module PACKMAN
  class LlvmCompilerSpec < CompilerSpec
    vendor 'llvm'
    compiler_command 'c'       => ['clang',   '-O2']
    compiler_command 'c++'     => ['clang++', '-O2']
    compiler_command 'fortran' => [nil,       nil]
    flag :rpath => -> rpath { "-Xlinker -rpath #{rpath}" }
    flag :cxxlib => '-lc++'
    check :version do
      `clang -v 2>&1`.match(/(\d+\.\d+)/)[1]
    end
  end
end
