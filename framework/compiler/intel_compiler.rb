module PACKMAN
  class IntelCompiler < Compiler
    vendor 'intel'
    compiler_command 'c'       => ['icc',   '-O2 -ip -fPIC']
    compiler_command 'c++'     => ['icpc',  '-O2 -ip -fPIC']
    compiler_command 'fortran' => ['ifort', '-O2 -ip -fPIC']
    flag :openmp => '-openmp'
    flag :pic => '-fPIC'
    flag :rpath => -> rpath { "-Wl,-rpath,#{rpath}" }
    check :version do
      `ifort -v 2>&1`.match(/(\d+\.\d+(\.\d+)?)/)[1]
    end
  end
end
