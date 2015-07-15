class Ruby_sequel < PACKMAN::Package
  url PACKMAN.gem_url('sequel-4.24.0.gem')
  sha1 '6710a3ba824eabfbdfeeb6702531231e3070af02'
  version '4.24.0'

  label :try_system_package_first
  label :not_set_bashrc

  depends_on 'sqlite'

  def install
    PACKMAN.gem "install sequel-#{version}.gem"
  end

  def remove
    PACKMAN.gem 'uninstall -x sequel'
  end

  def installed?
    PACKMAN.is_gem_installed? 'sequel', version
  end
end