module PACKMAN
  class Commands
    def self.switch
      if CommandLine.has_option? '-compiler_set_index'
        compiler_set_index = Integer(CommandLine.options['-compiler_set_index'])
      else
        compiler_set_index = Integer(ConfigManager.defaults[:compiler_set_index])
      end
      PACKMAN.report_notice "Switch to compiler set #{PACKMAN.green compiler_set_index.to_s}."
      ConfigManager.defaults[:compiler_set_index] = compiler_set_index
      CompilerManager.activate_compiler_set compiler_set_index
      PACKMAN.ln PACKMAN.link_root, PACKMAN.active_root, :remove_link_if_exist
      ConfigManager.write
    end
  end
end
