class Byacc < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.mac_gang?
      return File.exist? '/usr/bin/yacc'
    else
      return PACKMAN::OS.installed? 'byacc'
    end
  end

  def install_method
    if PACKMAN::OS.mac_gang?
      return 'You should install Xcode and command line tools.'
    else
      return PACKMAN::OS.how_to_install 'byacc'
    end
  end
end