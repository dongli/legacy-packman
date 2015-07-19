class Ruby_pg < PACKMAN::Package
  url PACKMAN.gem_url('pg-0.18.2.gem')
  sha1 '6b35a1a2b565277db26fabe9ce66e1fe62306528'
  version '0.18.2'

  label :try_system_package_first
  label :not_set_bashrc

  #depends_on 'postgresql'

  def install
    PACKMAN.gem "install pg-#{version}.gem"
  end

  def remove
    PACKMAN.gem 'uninstall pg'
  end

  def installed?
    PACKMAN.is_gem_installed? 'pg', version
  end
end
