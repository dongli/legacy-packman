module PACKMAN
  class CmakeHelper
    def self.wrap_flags language, flags
      case language
      when 'c'
        "-DCMAKE_C_FLAGS='#{flags}'"
      when 'c++'
        "-DCMAKE_CXX_FLAGS='#{flags}'"
      when 'fortran'
        "-DCMAKE_FORTRAN_FLAGS='#{flags}'"
      else
        PACKMAN::CLI.report_error "Unknown language #{PACKMAN::CLI.red language}!"
      end
    end

    def self.should_insert_before_command?; false; end
    def self.should_insert_after_command?; true; end
  end
end
