module PACKMAN
  class GccCompilerGroup < CompilerGroup
    vendor 'gnu'
    compiler_command 'c'       => ['gcc',      '-O2 -fPIC']
    compiler_command 'c++'     => ['g++',      '-O2 -fPIC']
    compiler_command 'fortran' => ['gfortran', '-O2 -fPIC']
    flag :openmp => '-fopenmp'
    flag :pic => '-fPIC'
    version_pattern /\d+\.\d+\.\d+/
  end
end
