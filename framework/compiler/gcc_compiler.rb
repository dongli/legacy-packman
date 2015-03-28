module PACKMAN
  class GccCompiler < Compiler
    vendor 'gnu'
    compiler_command 'c'       => ['gcc',      '-O2 -fPIC']
    compiler_command 'c++'     => ['g++',      '-O2 -fPIC']
    compiler_command 'fortran' => ['gfortran', '-O2 -fPIC']
    flag :openmp => '-fopenmp'
    flag :pic => '-fPIC'
    flag :rpath => -> rpath { "-Wl,-rpath,#{rpath}" }
    flag :cxxlib => '-lstdc++'
    check :version do
      `gcc -v 2>&1`.match(/^gcc [^ ]+ (\d+\.\d+\.\d+)/)[1]
    end
  end
end
