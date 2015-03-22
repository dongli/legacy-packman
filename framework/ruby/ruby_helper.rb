module PACKMAN
  class RubyHelper
    def self.delegated_methods
      [:gem_source, :is_gem_installed?, :gem]
    end

    GemSources = {
      :default => 'https://rubygems.org/downloads/',
      :rubygems => 'https://rubygems.org/downloads/',
      :taobao => 'https://ruby.taobao.org/gems/',
    }.freeze

    def self.change_gem_source name
      @@gem_source = GemSources[name]
    end

    def self.gem_source
      if not defined? @@gem_source
        if not ConfigManager.defaults['gem_source']
          @@gem_source = GemSources[:default]
        else
          @@gem_source = GemSources[ConfigManager.defaults['gem_source'].to_sym]
        end
      end
      @@gem_source
    end

    def self.is_gem_installed? name, version = nil
      Gem::Specification.each do |spec|
        if spec.name == name
          next if version and not spec.version.to_s == version
          spec.dependencies.each do |depend|
            next if depend.type == :development
            if not is_gem_installed? depend.name
              # Dependent gem is missing, so reinstall.
              return false
            end
          end
          return true
        end
      end
      return false
    end

    def self.gem cmd, *args
      cmd_str = 'gem '+cmd
      cmd_str << ' --local' if cmd == 'install'
      if cmd == 'uninstall'
        cmd_str << ' --executables'
        cmd_str << ' --ignore-dependencies'
      end
      cmd_str << ' --verbose' if CommandLine.has_option? '-verbose'
      cmd_str << ' --debug' if CommandLine.has_option? '-debug'
      cmd_str << ' '+args.join(' ')
      CLI.report_notice "Execute #{CLI.blue cmd_str}." if CommandLine.has_option? '-debug'
      if CommandLine.has_option? '-verbose'
        system "#{cmd_str} 2>&1"
      else
        res = `#{cmd_str} 2>&1`
      end
      if not $?.success?
        if CommandLine.has_option? '-verbose'
          CLI.report_error "Failed to do #{CLI.red cmd_str}!\n#{res}"
        else
          if res =~ /Gem::FilePermissionError/
            CLI.report_error "You do not have permission to do #{CLI.red cmd}!"
          else
            if cmd =~ /uninstall/
              if res =~ /not installed/
                CLI.report_error "Package #{CLI.red args.first} is not installed!"
              end
            else
              CLI.report_error "Failed to do #{CLI.red cmd_str}!\n#{res}"
            end
          end
        end
      end
    end
  end
end