module PACKMAN
  class Compiler
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
    def all_commands; active_spec.all_commands; end
    def command; active_spec.command; end
    def mpi_wrapper; active_spec.mpi_wrapper; end
    def mpi_wrapper= command; active_spec.mpi_wrapper = command; end
    def default_flags; active_spec.default_flags; end
    def flags; active_spec.flags; end
    def version; active_spec.version; end
    def flag flag
      if not active_spec.flags.has_key? flag
        CLI.report_error "Compiler #{vendor} does not provide flag #{CLI.red flag}! #{PACKMAN.contact_developer}"
      end
      active_spec.flags[flag]
    end

    def activate_compiler language, command
      # Record the real compiler command.
      active_spec.command = command
      # Execute the check blocks.
      active_spec.check_blocks.each do |name, block|
        next if active_spec.check_languages[name] and active_spec.check_languages[name] != language.to_sym
        # TODO: Check if block needs argument, then send command to it.
        begin
          if name == :version or name == :f2003
            active_spec.checked_items[name] = block.call command
          else
            active_spec.checked_items[name] = block.call
          end
        rescue => e
          PACKMAN.report_error "Failed to execute block #{PACKMAN.red name} in #{PACKMAN.blue self.class}!"
        end
        # Set shorthand query method.
        if [TrueClass, FalseClass].include? active_spec.checked_items[name].class
          method_body = <<-EOT.keep_indent
            def #{name}?
              #{active_spec.checked_items[name]}
            end
          EOT
          self.instance_eval method_body
        end
      end
      # Convert version string to VersionSpec.
      active_spec.version ||= VersionSpec.new active_spec.checked_items[:version].strip
    end

    class << self
      def normal
        eval "@@#{self.to_s.gsub(/PACKMAN::/, '')}_normal ||= CompilerAtom.new"
      end

      def vendor val; normal.vendor = val; end
      def version
        normal.version ||= VersionSpec.new normal.check_blocks[:version].call.strip
      end
      
      def command val
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

        normal.all_commands[language] = command
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
        if item.class == Hash
          language = item.keys.first
          name = item.values.first
          normal.check_languages[name] = language
        else
          name = item
        end
        normal.check_blocks[name] = block
      end
    end
  end
end
