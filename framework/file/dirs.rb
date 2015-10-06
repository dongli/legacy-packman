module PACKMAN
  def self.link_root
    "#{ConfigManager.install_root}/#{CompilerManager.active_compiler_set_index}"
  end

  def self.active_root
    "#{ConfigManager.install_root}/packman.active"
  end
end
