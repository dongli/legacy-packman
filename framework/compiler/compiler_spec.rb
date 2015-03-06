module PACKMAN
  class CompilerSpec
    attr_reader :normal, :active_spec

    def initialize requested_spec = nil
      hand_over_spec :normal

      set_active_spec requested_spec
    end

    def hand_over_spec name
      tmp = self.class.to_s.gsub(/PACKMAN::/, '')
      return if not self.class.class_variable_defined? :"@@#{tmp}_#{name}"
      spec = self.class.class_variable_get(:"@@#{tmp}_#{name}").clone
      instance_variable_set "@#{name}", spec
    end

    def set_active_spec requested_spec
      if requested_spec
        if self.respond_to? requested_spec
          @active_spec = self.send requested_spec
        end
      else
        @active_spec = normal
      end
    end

    def vendor; active_spec.vendor; end
    def compiler_commands; active_spec.compiler_commands; end
    def default_flags; active_spec.default_flags; end
    def flags; active_spec.flags; end
    def version; active_spec.version; end

    def activate_compiler language, command
      active_spec.query_version command
    end

    class << self
      def normal
        eval "@@#{self.to_s.gsub(/PACKMAN::/, '')}_normal ||= CompilerSpecSpec.new"
      end

      def vendor val; normal.vendor = val; end
      def version_pattern val; normal.version_pattern = val; end
      
      def compiler_command val
        if not val.class == Hash
          CLI.report_error "Compiler spec syntax error!"
        end
        if not val.keys.size == 1
          CLI.report_error "Compiler spec syntax error!"
        end
        if not val.values.first.size == 2
          CLI.report_error "Compiler spec syntax error!"
        end
        language = val.keys.first
        command = val.values.first.first
        default_flags = val.values.first.last

        normal.compiler_commands[language] = command
        normal.default_flags[language] = default_flags
      end

      def flag val
        if not val.class == Hash
          CLI.report_error "Compiler spec syntax error!"
        end
        val.each do |key, value|
          normal.flags[key] = value
        end
      end
    end
  end
end
