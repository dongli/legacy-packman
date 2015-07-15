class Ruby_sqlite3 < PACKMAN::Package
  url PACKMAN.gem_url('sqlite3-1.3.10.gem')
  sha1 '6bbe47c3e690568b9aaf2c7d9aca59a069608b1e'
  version '1.3.10'

  label :try_system_package_first
  label :not_set_bashrc

  depends_on 'sqlite'

  def install
    PACKMAN.gem "install sqlite3-#{version}.gem -- --use-system-libraries "+
      "--with-sqlite3-include=#{Sqlite.include} --with-sqlite3-lib=#{Sqlite.lib}"
  end

  def remove
    PACKMAN.gem 'uninstall sqlite3'
  end

  def installed?
    PACKMAN.is_gem_installed? 'sqlite3', version
  end
end