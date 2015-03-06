module PACKMAN
  class CompilerSpecSpec
    attr_accessor :vendor, :compiler_commands
    attr_accessor :default_flags, :flags
    attr_accessor :version_pattern, :version

    def initialize
      @compiler_commands = {}
      @default_flags = {}
      @flags = {}
    end

    def query_version command
      if not version_pattern
        CLI.report_error "Version pattern is not set in compiler spec #{CLI.red vendor}!"
      end
      res = `#{command} -v 2>&1`
      tmp = res.match(version_pattern)
      if tmp and tmp.size >= 2
        @version = VersionSpec.new tmp[1]
      else
        CLI.report_error "Unable to parse the version of #{CLI.red command}!"
      end
    end
  end
end
