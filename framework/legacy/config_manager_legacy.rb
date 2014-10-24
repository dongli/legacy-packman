module PACKMAN
  class ConfigManagerLegacy
    def self.check
      check_compiler_set
    end

    private

    def self.check_compiler_set
      if ConfigManager.defaults
        if not ConfigManager.defaults.has_key? 'compiler_set_index' and
           ConfigManager.defaults.has_key? 'compiler_set'
          CLI.report_error "Sorry, PACKMAN has changed #{CLI.red 'compiler_set'} in defaults section "+
            "in #{CommandLine.config_file} to #{CLI.red 'compiler_set_index'}."
        end
      end
      ConfigManager.package_options.each do |package_name, options|
        if options.has_key? 'compiler_set'
          CLI.report_error "Sorry, PACKMAN has changed #{CLI.red 'compiler_set'} in package_#{package_name.downcase} section"+
            "in #{CommandLine.config_file} to #{CLI.red 'compiler_set_indices'}."
        end
      end
    end
  end
end