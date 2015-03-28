module PACKMAN
  class OsAtom
    attr_accessor :vendor, :type, :version, :arch
    attr_accessor :package_managers
    attr_accessor :check_blocks, :checked_items

    def initialize
      @vendor = nil
      @type = nil
      @version = nil
      @package_managers = {}
      @check_blocks = {}
      @checked_items = {}
      @arch = `uname -m`.chomp
    end

    def inherit ancestor
      # Note: version and arch are not inherited, since they are specific.
      @vendor = ancestor.vendor if not @vendor
      @type = ancestor.type if not @type
      @package_managers.merge! ancestor.package_managers
      @check_blocks.merge! ancestor.check_blocks
    end
  end
end
