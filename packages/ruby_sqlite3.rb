class Ruby_sqlite3 < PACKMAN::Package
  url 'https://rubygems.org/downloads/sqlite3-1.3.10.gem'
  sha1 '6bbe47c3e690568b9aaf2c7d9aca59a069608b1e'
  version '1.3.10'

  label 'use_system_first'
  label 'no_bashrc'

  def install
    PACKMAN.gem 'install sqlite3-*.gem'
  end

  def remove
    PACKMAN.gem 'uninstall sqlite3'
  end

  def installed?
    PACKMAN.is_gem_installed? 'sqlite3', version
  end
end