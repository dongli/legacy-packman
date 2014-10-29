module PACKMAN
  class PackageSpec
    attr_reader :labels, :dependencies, :skip_distros
    attr_reader :conflict_packages, :conflict_reasons
    attr_reader :provided_stuffs, :master_package
    attr_reader :patches, :embeded_patches, :attachments
    attr_accessor :option_valid_types, :options

    CommonOptions = {
      'skip_test' => :boolean,
      'compiler_set_indices' => :integer_array,
      'use_binary' => :boolean
    }.freeze

    def initialize
      @labels = []
      @dependencies = []
      @skip_distros = []
      @conflict_packages = []
      @conflict_reasons = []
      @provided_stuffs = {}
      @patches = []
      @embeded_patches = []
      @attachments = []
      @option_valid_types = {}
      @options = {}

      CommonOptions.each do |key, type|
        option key => type
      end
    end

    def url val = nil
      if val
        @url = val
        @filename = File.basename(URI.parse(val).path)
      end
      return @url
    end

    def sha1 val = nil
      @sha1 = val if val
      return @sha1
    end

    def version val = nil
      @version = val if val
      return @version
    end

    def filename val = nil
      @filename = val if val
      return @filename
    end

    def label val; @labels << val if not @labels.include? val; end

    def has_label? val
      @labels.each do |label|
        return true if label =~ /#{val}/
      end
      return false
    end

    def depends_on val, condition = true
      return if val == :package_name or not val
      begin
        val = val.capitalize.to_sym
        if condition
          @dependencies << val if not @dependencies.include? val
        else
          @dependencies.delete val
        end
      rescue
        CLI.report_error 'Package definition syntax error!'
      end
    end

    def belongs_to val
      val = val.capitalize.to_sym
      if defined? @master_package and @master_package != val
        CLI.report_error 'Only one master package can be specified!'
      end
      begin
        @master_package = val
      rescue
        CLI.report_error 'Package definition syntax error!'
      end
    end

    def skip_on val; @skip_distros << val; end

    def skip_on? val; @skip_distros.include? val; end

    def conflicts_with val, &block
      @conflict_packages << val
      if block_given?
        instance_eval &block
      end
    end

    def because_they_both_provide val
      @conflict_reasons << val if not @conflict_reasons.include? val
    end

    def conflicts_with? val;  @conflict_packages.include? val; end

    def provide val; @provided_stuffs.merge! val; end

    def provide? val; @provided_stuffs.has_key? val; end

    def patch &block
      if block_given?
        new_patch = PackageSpec.new
        new_patch.instance_eval &block
        @patches.each do |patch|
          return if patch.sha1 == new_patch.sha1
        end
        @patches << new_patch
      end
    end

    def patch_embed val
      @embeded_patches << val if not @embeded_patches.include? val
    end

    def attach &block
      if block_given?
        attachment = PackageSpec.new
        attachment.instance_eval &block
        is_already_added = false
        @attachments.each do |a|
          if a.sha1 == attachment.sha1
            is_already_added = true
          end
        end
        @attachments << attachment if not is_already_added
      end
    end

    def option option_hash
      if option_hash.class == Hash
        if option_hash.size > 1
          CLI.report_error "Only one package option must be added once a time!"
        end
        key = option_hash.keys.first
        value = option_hash.values.first
        is_option_added = true if @options.has_key? key
        if value.class == Symbol
          return if is_option_added and @option_valid_types[key] == value
          @options[key] = PackageSpec.default_option_value value
          @option_valid_types[key] = value
        elsif value.class == TrueClass or value.class == FalseClass
          return if is_option_added
          @options[key] = value
          @option_valid_types[key] = :boolean
        elsif value.class == Fixnum
          if @option_valid_types[key] and
             @option_valid_types[key] == :integer_array
            return if is_option_added and @options[key] == [value]
            @options[key] = [value]
          else
            return if is_option_added and @options[key] == value
            @options[key] = value
            @option_valid_types[key] = :integer
          end
        elsif value.class == String
          return if is_option_added
          @options[key] = value
          @option_valid_types[key] = :string
        else
          CLI.report_error "Unexpected package option #{CLI.red option_hash}!"
        end
        if is_option_added
          CLI.report_warning "Package option #{CLI.red option_hash} has already been added!"
        end
      else
        CLI.report_error "The valid type or default value for the package option #{CLI.red option_hash} is not provided!"
      end
    end

    def has_option? key
      options.has_key? key
    end

    def update_option key, value, ignore_error = false
      return if not options.has_key? key
      case option_valid_types[key]
      when :boolean
        if value == nil
          options[key] = true
        elsif value.class == TrueClass or value.class == FalseClass
          options[key] = value
        elsif value == 'true' or value == 'false'
          options[key] = eval value
        else
          CLI.report_error "A boolean is needed for option #{CLI.red key} or nothing at all!" if not ignore_error
        end
      when :integer_array
        if value.class == Fixnum
          options[key] << value
        elsif value.class == Array
          options[key] += value # Keep previous values.
        elsif value.class == String
          begin
            options[key] += eval "[#{value}]"
          rescue
            CLI.report_error "Failed to parse the value (#{CLI.red value}) of option #{CLI.red key}!" if not ignore_error
          end
        else
          CLI.report_error "A integer array is needed for option #{CLI.red key}!" if not ignore_error
        end
        options[key].uniq!
        options[key].each { |x| raise ArgumentError if x.class != Fixnum }
      when :package_name
        if not Package.all_package_names.include? value
          CLI.report_error "A package name is needed for option #{CLI.red key}!" if not ignore_error
        end
        options[key] = value
      when :string
        options[key] = value
      end
    end

    def self.default_option_value type
      case type
      when :boolean
        false
      when :integer_array
        []
      when :package_name
        nil
      when :string
        nil
      else
        CLI.report_error "Invalid option type #{CLI.red type}!"
      end
    end
  end
end
