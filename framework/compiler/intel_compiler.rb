module PACKMAN
  class IntelCompiler < Compiler
    vendor 'intel'
    command 'c'       => ['icc',   '-O2 -ip -fPIC']
    command 'c++'     => ['icpc',  '-O2 -ip -fPIC']
    command 'fortran' => ['ifort', '-O2 -ip -fPIC']
    flag :openmp => '-openmp'
    flag :pic => '-fPIC'
    flag :rpath => -> rpath { "-Wl,-rpath,#{rpath}" }
    check :version do |command|
      `#{command} -v 2>&1`.match(/(\d+\.\d+(\.\d+)?)/)[1]
    end
    check :fortran => :f2003 do |command|
      res = `#{command} -std03 2>&1`
      res.match(/ignoring unknown option/) ? false : true
    end
  end
end
