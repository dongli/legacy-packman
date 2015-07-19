class Ruby_highline < PACKMAN::Package
  url PACKMAN.gem_url('highline-1.7.2.gem')
  sha1 'd7114ed98c5651b928cc7195aded7b0000e09689'
  version '1.7.2'

  label :try_system_package_first
  label :not_set_bashrc

  def install
    PACKMAN.gem "install highline-#{version}.gem"
  end

  def remove
    PACKMAN.gem 'uninstall -x highline'
  end

  def installed?
    PACKMAN.is_gem_installed? 'highline', version
  end
end