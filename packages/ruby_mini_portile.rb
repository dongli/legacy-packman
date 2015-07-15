class Ruby_mini_portile < PACKMAN::Package
  url PACKMAN.gem_url('mini_portile-0.6.2.gem')
  sha1 '696b940eb4ff8076a2080684046da1d2b10f41b8'
  version '0.6.2'

  label :try_system_package_first
  label :not_set_bashrc

  def install
    PACKMAN.gem 'install', "mini_portile-#{version}.gem"
  end

  def remove
    PACKMAN.gem 'uninstall', 'mini_portile'
  end

  def installed?
    PACKMAN.is_gem_installed? 'mini_portile', version
  end
end