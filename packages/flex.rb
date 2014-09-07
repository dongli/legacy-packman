class Flex < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.debian_gang? or PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.installed? 'flex'
    elsif PACKMAN::OS.mac_gang?
      return File.exist? '/usr/bin/flex'
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang? or PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.how_to_install 'flex'
    elsif PACKMAN::OS.mac_gang?
      return 'You should install Xcode and command line tools.'
    end
  end
end
