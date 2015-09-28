module PACKMAN
  module Files
    class Inventory
      def initialize link_root
        @path = "#{link_root}/packman.inventory"
      end

      def item package
        "#{package.class.to_s.upcase} #{package.sha1} #{package.revision}\n"
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
