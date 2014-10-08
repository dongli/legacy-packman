module PACKMAN
  class Commands
    def self.config
      PACKMAN.check_command 'vim'
      editor = 'vim'
      system "#{editor} -c 'set filetype=ruby' #{CommandLine.config_file}"
    end
  end
end
