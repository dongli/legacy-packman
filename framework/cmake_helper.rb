module PACKMAN
  class CmakeHelper
    def wrap_flags(language, default_flags)
      case language
      when 'c'
        "-DCMAKE_C_FLAGS='#{default_flags}'"
      when 'c++'
        "-DCMAKE_CXX_FLAGS='#{default_flags}'"
      when 'fortran'
        "-DCMAKE_FORTRAN_FLAGS='#{default_flags}'"
      else
        PACKMAN.report_error "Unknown language #{PACKMAN::Tty.red}#{language}#{PACKMAN::Tty.reset}!"
      end
    end
  end
end
