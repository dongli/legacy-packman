module PACKMAN
  class PackageSpec
    attr_reader :labels, :dependencies, :skip_distros
    attr_reader :conflict_packages, :provided_stuffs
    attr_reader :patches, :embeded_patches, :attachments

    def initialize
      @labels = []
      @dependencies = []
      @skip_distros = []
      @conflict_packages = []
      @provided_stuffs = {}
      @patches = []
      @embeded_patches = []
      @attachments = []
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

    def has_label? val; @labels.include? val; end

    def depends_on val; @dependencies << val; end

    def skip_on val; @skip_distros << val; end

    def skip_on? val; @skip_distros.include? val; end

    def conflicts_with val; @conflict_packages << val; end

    def conflicts_with? val;  @conflict_packages.include? val; end

    def provide val; @provided_stuffs.merge! val; end

    def provide? val; @provided_stuffs.has_key? val; end

    def patch &block
      if block_given?
        @patches << PackageSpec.new
        @patches.last.instance_eval &block
      end
    end

    def patch_embed val; @embeded_patches << val; end

    def attach &block
      if block_given?
        @attachments << PackageSpec.new
        @attachments.last.instance_eval &block
      end
    end
  end
end
