module PACKMAN
  class PackageAlias
    def self.delegated_methods
      [:alias, :antialias]
    end

    ALIAS_MAP = {
      :Readline => :Readline_,
      :Zlib => :Zlib_
    }.freeze

    def self.alias name, *options
      name = name.to_s.capitalize.to_sym
      if not ALIAS_MAP.keys.include? name
        res = name
      else
        res = ALIAS_MAP[name]
      end
      options.include?(:downcase) ? res.to_s.downcase.to_sym : res
    end

    def self.antialias name, *options
      name = name.to_s.capitalize.to_sym
      if not ALIAS_MAP.values.include? name
        res = name
      else
        res = ALIAS_MAP.key name
      end
      options.include?(:downcase) ? res.to_s.downcase.to_sym : res
    end
  end
end
