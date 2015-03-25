module PACKMAN
  class PgiCompilerSpec < CompilerSpec
    vendor 'pgi'
    compiler_command 'c'       => ['pgcc',      '-O2 -fPIC']
    compiler_command 'c++'     => ['pgcpp',     '-O2 -fPIC']
    compiler_command 'fortran' => ['pgfortran', '-O2 -fPIC']
    flag :openmp => '-mp'
    flag :pic => '-fPIC'
    flag :rpath => -> rpath { "-Wl,-rpath,#{rpath}" }
    check :version do
      `pgcc -V 2>&1`.match(/\d+\.\d+-\d+/)[0]
    end
  end
end
