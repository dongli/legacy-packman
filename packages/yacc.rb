class Yacc < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN.debian? or PACKMAN.redhat?
      return PACKMAN.os_installed? 'byacc'
    elsif PACKMAN.mac?
      return File.exist? '/usr/bin/yacc'
    end
  end

  def install_method
    if PACKMAN.debian? or PACKMAN.redhat?
      return PACKMAN.os_how_to_install 'byacc'
    elsif PACKMAN.mac?
      return 'You should install Xcode and command line tools.'
    end
  end
end
