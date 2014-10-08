module PACKMAN
  class PackageSpec
    attr_reader :labels, :dependencies, :skip_distros
    attr_reader :conflict_packages, :conflict_reasons
    attr_reader :provided_stuffs
    attr_reader :patches, :embeded_patches, :attachments
    attr_accessor :option_valid_types, :options

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

    def label val; @labels << val; end

    def has_label? val
      @labels.each do |label|
        return true if label =~ /#{val}/
      end
      return false
    end

    def depends_on val
      return if val == :package_name
      begin
        val = val.capitalize.to_sym
        @dependencies << val if not @dependencies.include? val
      rescue
        CLI.report_error "Package definition syntax error!"
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
        @attachments << PackageSpec.new
        @attachments.last.instance_eval &block
      end
    end

    def option val
      if val.class == Hash
        @option_valid_types.merge! val
        val.each_key do |key|
          @options[key] ||= nil
        end
      else
        @options[val] ||= nil
      end
    end
  end
end
