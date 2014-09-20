module PACKMAN
  class AutotoolHelper
    def self.wrap_flags(language, default_flags)
      case language
      when 'c'
        "CFLAGS='#{default_flags}'"
      when 'c++'
        "CXXFLAGS='#{default_flags}'"
      when 'fortran'
        "FCFLAGS='#{default_flags}'"
      else
        PACKMAN::CLI.report_error "Unknown language #{PACKMAN::CLI.red language}!"
      end
    end
  end
end
