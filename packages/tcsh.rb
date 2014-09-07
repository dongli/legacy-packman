class Tcsh < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.mac_gang?
      return true
    else
      return PACKMAN::OS.installed? 'tcsh'
    end
  end

  def install_method
    if PACKMAN::OS.mac_gang?
      return 'Mac should already install Tcsh!'
    else
      return PACKMAN::OS.how_to_install 'tcsh'
    end
  end
end
