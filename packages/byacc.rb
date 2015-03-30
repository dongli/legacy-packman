class Byacc < PACKMAN::Package
  label 'should_be_provided_by_system'

  def installed?
    if PACKMAN.mac?
      return File.exist? '/usr/bin/yacc'
    else
      return PACKMAN.os_installed? 'byacc'
    end
  end

  def install_method
    if PACKMAN.mac?
      return 'You should install Xcode and command line tools.'
    else
      return PACKMAN.os_how_to_install 'byacc'
    end
  end
end
