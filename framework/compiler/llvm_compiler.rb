module PACKMAN
  class LlvmCompiler < Compiler
    vendor :llvm
    command :c       => [ 'clang',   '-O2' ]
    command :cxx     => [ 'clang++', '-O2' ]
    command :fortran => [   nil,      nil  ]
    flag :rpath => -> rpath { "-Wl,-rpath,#{rpath}" }
    flag :cxxlib => '-lc++'
    check :version do |command|
      res = `#{command} -v 2>&1`
      if res =~ /Agreeing .* license requires admin privileges, please re-run as root via sudo./
        PACKMAN.report_error <<-EOT.keep_indent
          You need to agree Xcode license by running:
          #{PACKMAN.blue '==>'} sudo clang
        EOT
      end
      res.match(/(\d+\.\d+)/)[1]
    end
  end
end
