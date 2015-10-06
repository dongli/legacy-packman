module PACKMAN
  class GnuCompiler < Compiler
    vendor :gnu
    command :c       => ['gcc',      '-O2 -fPIC']
    command :cxx     => ['g++',      '-O2 -fPIC']
    command :fortran => ['gfortran', '-O2 -fPIC']
    flag :openmp => '-fopenmp'
    flag :pic => '-fPIC'
    flag :rpath => -> rpath { "-Wl,-rpath,#{rpath}" }
    flag :cxxlib => '-lstdc++'
    check :version do |command|
      `#{command} -v 2>&1`.match(/^gcc [^ ]+ (\d+\.\d+\.\d+)/)[1]
    end
    check :fortran => :f2003 do |command|
      res = `#{command} -std=f2003 2>&1`
      res.match(/unrecognized command line option/) ? false : true
    end
  end
end
