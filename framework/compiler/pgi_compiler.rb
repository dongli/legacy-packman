module PACKMAN
  class PgiCompiler < Compiler
    vendor 'pgi'
    command 'c'       => ['pgcc',      '-O2 -fPIC']
    command 'cxx'     => ['pgcpp',     '-O2 -fPIC']
    command 'fortran' => ['pgfortran', '-O2 -fPIC']
    flag :openmp => '-mp'
    flag :pic => '-fPIC'
    flag :rpath => -> rpath { "-Wl,-rpath,#{rpath}" }
    check :version do |command|
      `#{command} -V 2>&1`.match(/\d+\.\d+-\d+/)[0]
    end
    check :fortran => :f2003 do |command|
      true # pgfortran implicitly has Fortran 2003 feature.
    end
  end
end
