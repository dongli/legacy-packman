module PACKMAN
  class PgiCompilerSpec < CompilerSpec
    vendor 'pgi'
    compiler_command 'c'       => ['pgcc',      '-O2 -fPIC']
    compiler_command 'c++'     => ['pgc++',     '-O2 -fPIC']
    compiler_command 'fortran' => ['pgfortran', '-O2 -fPIC']
    flag :openmp => '-mp'
    flag :pic => '-fPIC'
    version_pattern /(\d+\.\d+-\d+)/
  end
end
