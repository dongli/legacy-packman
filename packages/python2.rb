class Python2 < PACKMAN::Package
  label :try_system_package_first

  def installed?
    if PACKMAN.debian?
      PACKMAN.os_installed? ['python-dev']
    elsif PACKMAN.redhat?
      PACKMAN.os_installed? ['python-devel']
    elsif PACKMAN.mac?
      true
    end
  end

  def install_method
    if PACKMAN.debian?
      PACKMAN.os_how_to_install ['python-dev']
    elsif PACKMAN.redhat?
      PACKMAN.os_how_to_install ['python-devel']
    end
  end
end
