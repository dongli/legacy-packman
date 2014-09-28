module PACKMAN
  class AutotoolHelper
    def self.wrap_flags language, flags
      case language
      when 'c'
        "CFLAGS=\"$CFLAGS #{flags}\""
      when 'c++'
        "CXXFLAGS=\"$CXXFLAGS #{flags}\""
      when 'fortran'
        "FCFLAGS=\"$FCFLAGS #{flags}\""
      else
        PACKMAN::CLI.report_error "Unknown language #{PACKMAN::CLI.red language}!"
      end
    end

    def self.should_insert_before_command?; true; end
    def self.should_insert_after_command?; false; end
  end
end
