module PACKMAN
  class GccCompilerGroup < CompilerGroup
    vendor 'gnu'
    compiler_command 'c'       => ['gcc',      '-O2']
    compiler_command 'c++'     => ['g++',      '-O2']
    compiler_command 'fortran' => ['gfortran', '-O2']
    flag 'openmp' => '-fopenmp'
    version_pattern /\d+\.\d+\.\d+/
  end
end
