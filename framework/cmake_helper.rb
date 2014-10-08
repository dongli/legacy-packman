module PACKMAN
  class CmakeHelper
    def self.wrap_flags language, flags, cmd_args
      # NOTE: We should not override the flags set by the specific package definition class.
      case language
      when 'c'
        if cmd_args.match /-DCMAKE_C_FLAGS/
          cmd_args.gsub! /-DCMAKE_C_FLAGS='([^']*)'/, "-DCMAKE_C_FLAGS='\\1 #{flags}'"
          return nil
        else
          "-DCMAKE_C_FLAGS='#{flags}'"
        end
      when 'c++'
        if cmd_args.match /-DCMAKE_CXX_FLAGS/
          cmd_args.gsub! /-DCMAKE_CXX_FLAGS='([^']*)'/, "-DCMAKE_CXX_FLAGS='\\1 #{flags}'"
          return nil
        else
          "-DCMAKE_CXX_FLAGS='#{flags}'"
        end
      when 'fortran'
        if cmd_args.match /-DCMAKE_FORTRAN_FLAGS/
          cmd_args.gsub! /-DCMAKE_FORTRAN_FLAGS='([^']*)'/, "-DCMAKE_FORTRAN_FLAGS='\\1 #{flags}'"
          return nil
        else
          "-DCMAKE_FORTRAN_FLAGS='#{flags}'"
        end
      else
        CLI.report_error "Unknown language #{CLI.red language}!"
      end
    end

    def self.should_insert_before_command?; false; end
    def self.should_insert_after_command?; true; end
  end
end
