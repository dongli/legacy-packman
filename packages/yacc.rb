class Yacc < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.debian_gang? or PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.installed? 'byacc'
    elsif PACKMAN::OS.mac_gang?
      return File.exist? '/usr/bin/yacc'
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang? or PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.how_to_install 'byacc'
    elsif PACKMAN::OS.mac_gang?
      return 'You should install Xcode and command line tools.'
    end
  end
end
