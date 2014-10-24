class Patch < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.redhat_gang?
      PACKMAN::OS.installed? 'patch'
    elsif PACKMAN::OS.mac_gang?
      File.exist? '/usr/bin/patch'
    end
  end

  def install_method
    if PACKMAN::OS.redhat_gang?
      PACKMAN::OS.how_to_install 'patch'
    elsif PACKMAN::OS.mac_gang?
      'Mac should provide patch when command line tools are installed!'
    end
  end
end
