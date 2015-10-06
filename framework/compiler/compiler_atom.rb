module PACKMAN
  class CompilerAtom
    attr_accessor :vendor, :version
    attr_accessor :command, :mpi_wrapper, :all_commands
    attr_accessor :default_flags, :flags
    attr_accessor :check_blocks, :checked_items, :check_languages

    def initialize
      @command = nil
      @mpi_wrapper = nil
      @all_commands = {}
      @default_flags = {}
      @flags = {}
      @check_blocks = {}
      @checked_items = {}
      @check_languages = {}
    end

    def to_hash
      {
        :vendor => vendor,
        :version => version.major_minor
      }
    end
  end
end
