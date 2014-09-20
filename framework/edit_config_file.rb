module PACKMAN
  def self.edit_config_file
    check_command 'vim'
    editor = 'vim'
    system "#{editor} -c 'set filetype=ruby' #{CommandLine.config_file}"
  end
end
