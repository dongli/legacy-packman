module PACKMAN
  class CmakeHelper
    def self.wrap_flags language, default_flags
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

    def self.should_insert_before_command?; false; end
    def self.should_insert_after_command?; true; end
  end
end
