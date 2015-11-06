module PACKMAN
  module PackageBinary
    def self.included base
      base.extend self
    end

    def match_binary
      res = nil
      return res if not @binary or ( not @stable.has_label? :external_binary and not CompilerManager.active_compiler_set )
      compilers = CompilerManager.active_compiler_set.compilers if CompilerManager.active_compiler_set
      @binary.each do |binary_spec|
        next if not binary_spec.os[:type] == PACKMAN.os.type
        next if not eval "PACKMAN.os.version #{binary_spec.os[:version][:compare_operator]} binary_spec.os[:version][:base]"
        if not binary_spec.compiler_set.empty? and not self.stable.has_label? :compiler_insensitive
          compiler_matched = false
          binary_spec.compiler_set.each do |language, compiler|
            next if not compilers[language].vendor == compiler[:vendor]
            next if not eval "compilers[language].version #{compiler[:version][:compare_operator]} compiler[:version][:base]"
            compiler_matched = true
            break
          end
          next if not compiler_matched
        end
        res = binary_spec
        break
      end
      res
    end

    def has_binary?
      match_binary != nil
    end
  end
end
