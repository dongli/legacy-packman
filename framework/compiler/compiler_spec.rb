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
      active_spec.check_blocks.each do |name, block|
        begin
          active_spec.checked_items[name] = block.call
        rescue => e
          if name == :version and not PACKMAN.does_command_exist? command
            PACKMAN.report_error "Command #{PACKMAN.red command} does not exist! Check your compiler sets in the configure file."
          else
            PACKMAN.report_error "Failed to execute block #{PACKMAN.red name} in #{PACKMAN.blue self.class}!"
          end
        end
      end
      active_spec.version ||= VersionSpec.new active_spec.checked_items[:version].strip
    end

    class << self
      def normal
        eval "@@#{self.to_s.gsub(/PACKMAN::/, '')}_normal ||= CompilerSpecSpec.new"
      end

      def vendor val; normal.vendor = val; end
      def version
        normal.version ||= VersionSpec.new normal.check_blocks[:version].call.strip
      end
      
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

      def check item, &block
        normal.check_blocks[item] = block
      end
    end
  end
end
