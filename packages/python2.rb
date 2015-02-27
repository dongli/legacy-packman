class Python2 < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.debian_gang?
      PACKMAN::OS.installed? ['python-dev']
    elsif PACKMAN::OS.redhat_gang?
      PACKMAN::OS.installed? ['python-devel']
    elsif PACKMAN::OS.mac_gang?
      true
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang?
      PACKMAN::OS.how_to_install ['python-dev']
    elsif PACKMAN::OS.redhat_gang?
      PACKMAN::OS.how_to_install ['python-devel']
    end
  end
end
