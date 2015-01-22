module PACKMAN
  class Commands
    def self.fix
      legacy_classes = []
      PACKMAN.constants.each do |c|
        legacy_classes << c if c.to_s =~ /Legacy/
      end
      legacy_classes.each do |legacy_class|
        legacy = eval "#{legacy_class}.new"
        legacy.methods.each do |fix_method|
          if fix_method.to_s =~ /fix_/
            legacy.send fix_method
          end
        end
      end
    end
  end
end
