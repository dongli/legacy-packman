class M4 < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.mac_gang?
      return File.exist? '/usr/bin/m4'
    else
      return PACKMAN::OS.installed? 'm4'
    end
  end

  def install_method
    if PACKMAN::OS.mac_gang?
      return 'You should install Xcode and command line tools.'
    else
      return PACKMAN::OS.how_to_install 'm4'
    end
  end
end