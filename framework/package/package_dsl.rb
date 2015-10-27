module PACKMAN
  module PackageDSL
    def self.included base
      base.extend self
    end

    def name
      PackageAlias.antialias self, :downcase
    end

    def url val
      stable.url val
    end

    def sha1 val
      stable.sha1 val
    end

    def version val = nil
      stable.version val
    end

    def filename val
      stable.filename val
    end

    def label val
      stable.label val
    end

    def conflicts_with package_name, reason
      stable.conflicts_with package_name, reason
    end

    def depends_on package_name
      stable.depends_on package_name
    end

    def belongs_to package_name
      stable.belongs_to package_name
    end

    def provides val
      stable.provides val
    end

    def option option_hash
      stable.option option_hash
      option_name = option_hash.keys.first
      option_type = stable.option_valid_types[option_name]
      create_option_shortcut option_name, option_type, self, :"@@#{name}_stable", true
    end

    def revision val
      stable.revision val
    end

    def patch option = nil, &block
      if option == :embed
        data = ''
        start = false
        File.open("#{ENV['PACKMAN_ROOT']}/packages/#{name}.rb", 'r').each do |line|
          if line =~ /__END__/
            start = true
            next
          end
          data << line if start
        end
        stable.patch_embed data
      elsif block_given?
        stable.patch &block
      end
    end

    def attach name, option = nil, &block
      stable.attach name, &block
      if option == :for_all
        devel.attach name, &block if devel
        if binary
          binary.each_value do |b|
            b.attach name, &block
          end
        end
      end
    end

    def stable
      eval "@@#{name}_stable ||= PackageSpec.new"
    end

    def head &block
      eval "@@#{name}_head ||= PackageSpec.new"
      return eval "@@#{name}_head" if not block_given?
      eval "@@#{name}_head.instance_eval &block"
      eval "@@#{name}_head.label :head"
      eval "@@#{name}_head.version :head"
    end

    def binary &block
      eval "@@#{name}_binary ||= []"
      return eval "@@#{name}_binary" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval &block
      spec.label :binary
      eval <<-EOT
        if @@#{name}_binary.empty?
          @@#{name}_binary << spec
        else
          found = false
          @@#{name}_binary.each do |binary_spec|
            if binary_spec.os[:type] == spec.os[:type] and
               binary_spec.os[:version][:compare_operator] == spec.os[:version][:compare_operator] and
               binary_spec.os[:version][:base].to_s == spec.os[:version][:base].to_s and
               binary_spec.sha1 == spec.sha1
              found = true
              break
            end
          end
          @@#{name}_binary << spec if not found
        end
      EOT
    end

    def history &block
      eval "@@#{name}_history ||= {}"
      return eval "@@#{name}_history" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval &block
      eval "@@#{name}_history[spec.version.to_s] = spec"
    end

    def add_method object, method_body, is_temporary
      if is_temporary
        object.class_eval method_body.gsub('def ', 'def self.')
      else
        object.instance_eval method_body
      end
    end

    def create_option_shortcut option_name, option_type, object, spec, is_temporary = false
      method_bodies = []
      if option_type.class == Array
        # The option can have multiple types.
        option_type.each do |type|
          create_option_shortcut option_name, type, object, spec, is_temporary
        end
        # Define a method for querying the type of the option.
        method_body = <<-EOT
          def option_type option_name
            #{spec}.option_actual_types[option_name]
          end
        EOT
        add_method object, method_body, is_temporary
      else
        case option_type
        when :boolean
          method_bodies << <<-EOT
            def #{option_name}?
              #{spec}.options[:#{option_name}]
            end
            def #{option_name}= value
              #{spec}.options[:#{option_name}] = value
            end
          EOT
        when :package_name
          if option_name.to_s =~ /use_/
            package_name = option_name.to_s.gsub('use_', '')
            method_bodies << <<-EOT
              def #{package_name}
                # When option is boolean, query option value from defaults in ConfigManager.
                if respond_to? :option_type
                  if option_type(:#{option_name}) == :boolean
                    return PACKMAN::ConfigManager.defaults[:#{package_name}]
                  end
                end
                #{spec}.options[:#{option_name}]
              end
            EOT
            method_bodies << <<-EOT
              def #{option_name}?
                #{spec}.options[:#{option_name}]
              end
            EOT
          else
            CLI.report_error "Unsupported option name #{CLI.red option_name}!"
          end
        else
          method_bodies << <<-EOT
            def #{option_name}
              #{spec}.options[:#{option_name}]
            end
            def #{option_name}= value
              #{spec}.options[:#{option_name}] = value
            end
          EOT
        end
        method_bodies.each do |method_body|
          add_method object, method_body, is_temporary
        end
      end
    end

    def create_attachment_shortcut attach_name, object, spec
      object.instance_eval "@#{attach_name} = stable.attachments[attach_name]"
      object.instance_eval <<-EOT
        def #{attach_name}; @#{attach_name}; end
      EOT
    end
  end
end
