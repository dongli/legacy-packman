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
        PACKMAN.report_error "Unknown language #{PACKMAN::Tty.red}#{language}#{PACKMAN::Tty.reset}!"
      end
    end
  end
end
