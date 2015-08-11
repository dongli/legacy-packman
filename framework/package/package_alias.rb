module PACKMAN
  class PackageAlias
    @@Alias = {
      :Readline => :Readline_
    }.freeze

    def self.check name
      name = name.to_s.to_sym
      if not @@Alias.include? name
        name
      else
        @@Alias[name]
      end
    end
  end
end
