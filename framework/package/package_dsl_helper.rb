module PACKMAN
  module PackageDslHelper
    def self.create_option_shortcut option_name, option_type, object, spec, is_temporary = false
      method_bodies = []
      case option_type
      when :boolean
        method_bodies << <<-EOT
          def #{option_name}?
            #{spec}.options["#{option_name}"]
          end
        EOT
      when :package_name
        if option_name =~ /use_/
          method_bodies << <<-EOT
            def #{option_name.gsub('use_', '')}
              #{spec}.options["#{option_name}"]
            end
          EOT
          method_bodies << <<-EOT
            def #{option_name}?
              #{spec}.options["#{option_name}"]
            end
          EOT
        else
          CLI.report_error "Unsupported option name #{CLI.red option_name}!"
        end
      else
        method_bodies << <<-EOT
          def #{option_name}
            #{spec}.options["#{option_name}"]
          end
        EOT
      end
      method_bodies.each do |method_body|
        if is_temporary
          object.class_eval method_body.gsub('def ', 'def self.')
        else
          object.instance_eval method_body
        end
      end
    end
  end
end