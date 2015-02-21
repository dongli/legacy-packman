module PACKMAN
  class RubyHelper
    def self.delegated_methods
      [:is_gem_installed?, :gem]
    end

    def self.is_gem_installed? name, version = nil
      Gem::Specification.each do |spec|
        if spec.name == name
          next if version and not spec.version.to_s == version
          return true
        end
      end
      return false
    end

    def self.gem command
      res = `gem #{command} 2>&1`
      if not $?.success?
        if res =~ /Gem::FilePermissionError/
          CLI.report_error "You do not have permission to do #{CLI.red command}!"
        else
          if command =~ /uninstall/
            if res =~ /not installed/
              CLI.report_error "Package #{CLI.red command.split.last} is not installed!"
            end
          else
            CLI.report_error "Failed to do #{CLI.red command}!\n#{res}"
          end
        end
      end
    end
  end
end