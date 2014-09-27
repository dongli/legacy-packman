module PACKMAN
  class CompilerGroupSpec
    attr_accessor :vendor, :compiler_commands, :default_flags
    attr_accessor :flags, :version_pattern, :version

    def initialize
      @compiler_commands = {}
      @default_flags = {}
      @flags = {}
    end

    def query_version
      # Set compiler group version (use C compiler).
      if not version_pattern
        PACKMAN::CLI.report_error "Version pattern is not set in compiler group #{PACKMAN::CLI.red vendor}!"
      end
      res = `#{compiler_commands['c']} -v 2>&1`
      tmp = res.match(version_pattern)
      if tmp
        @version = tmp[0]
      end
    end
  end
end
