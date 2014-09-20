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
        PACKMAN::CLI.report_error "Unknown language #{PACKMAN::CLI.red language}!"
      end
    end
  end
end
