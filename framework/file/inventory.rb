module PACKMAN
  module Files
    class Inventory
      def initialize
        @path = "#{PACKMAN.link_root}/packman.inventory"
      end

      def item package
        "#{package.name.upcase} #{package.version} #{package.revision}\n"
      end

      def add package
        PACKMAN.append @path, item(package)
      end

      def include? package
        PACKMAN.contain? @path, item(package)
      end

      def remove package
        PACKMAN.delete_from_file @path, item(package), :no_error
      end
    end
  end
end
