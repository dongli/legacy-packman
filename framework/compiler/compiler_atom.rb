module PACKMAN
  class CompilerAtom
    attr_accessor :vendor, :version, :compiler_commands
    attr_accessor :default_flags, :flags
    attr_accessor :check_blocks, :checked_items

    def initialize
      @compiler_commands = {}
      @default_flags = {}
      @flags = {}
      @check_blocks = {}
      @checked_items = {}
    end
  end
end
