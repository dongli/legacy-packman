module PACKMAN
  class IntelCompilerSpec < CompilerSpec
    vendor 'intel'
    compiler_command 'c'       => ['icc',   '-O2 -ip -fPIC']
    compiler_command 'c++'     => ['icpc',  '-O2 -ip -fPIC']
    compiler_command 'fortran' => ['ifort', '-O2 -ip -fPIC']
    flag :openmp => '-openmp'
    flag :pic => '-fPIC'
    version_pattern /(\d+\.\d+(\.\d+)?)/
  end
end
