class Tcsh < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN.mac?
      return true
    else
      return PACKMAN.os_installed? 'tcsh'
    end
  end

  def install_method
    if PACKMAN.mac?
      return 'Mac should already install Tcsh!'
    else
      return PACKMAN.os_how_to_install 'tcsh'
    end
  end
end
