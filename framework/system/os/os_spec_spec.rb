module PACKMAN
  class OsSpecSpec
    attr_accessor :vendor, :type, :distro, :version, :arch
    attr_accessor :version_query_block, :package_managers

    def initialize
      @vendor = nil
      @type = nil
      @distro = nil
      @version = nil
      @version_query_block = nil
      @package_managers = {}
      @arch = `uname -m`.chomp
    end

    def inherit ancestor
      # Note: version and arch are not inherited, since they are specific.
      @vendor = ancestor.vendor if not @vendor
      @type = ancestor.type if not @type
      @distro = ancestor.distro if not @distro
      @version_query_block = ancestor.version_query_block if not @version_query_block
      @package_managers.merge! ancestor.package_managers
    end
  end
end
