module PACKMAN
  class GccCompilerSpec < CompilerSpec
    vendor 'gnu'
    compiler_command 'c'       => ['gcc',      '-O2 -fPIC']
    compiler_command 'c++'     => ['g++',      '-O2 -fPIC']
    compiler_command 'fortran' => ['gfortran', '-O2 -fPIC']
    flag :openmp => '-fopenmp'
    flag :pic => '-fPIC'
    flag :rpath => -> rpath { "-Wl,-rpath=#{rpath}" }
    flag :cxxlib => '-lstdc++'
    version_pattern /^gcc [^ ]+ (\d+\.\d+\.\d+)/
  end
end
