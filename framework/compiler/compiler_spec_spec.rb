module PACKMAN
  class CompilerSpecSpec
    attr_accessor :vendor, :compiler_commands
    attr_accessor :default_flags, :customized_flags
    attr_accessor :flags, :version_pattern, :version

    def initialize
      @compiler_commands = {}
      @default_flags = {}
      @customized_flags = {}
      @flags = {}
    end

    def query_version language
      if not version_pattern
        CLI.report_error "Version pattern is not set in compiler spec #{CLI.red vendor}!"
      end
      res = `#{compiler_commands[language]} -v 2>&1`
      tmp = res.match(version_pattern)
      if tmp and tmp.size >= 2
        @version = VersionSpec.new tmp[1]
      else
        CLI.report_error "Unable to parse the version of #{CLI.red compiler_commands[language]}!"
      end
    end

    def append_customized_flags language, flags
      @customized_flags[language] ||= ''
      @customized_flags[language] << ' '+flags
    end

    def clean_customized_flags language
      @customized_flags[language] = nil
    end
  end
end
