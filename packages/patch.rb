class Patch < PACKMAN::Package
  label 'should_be_provided_by_system'

  def installed?
    if PACKMAN.redhat? or PACKMAN.debian?
      PACKMAN.os_installed? 'patch'
    elsif PACKMAN.mac? or PACKMAN.cygwin?
      File.exist? '/usr/bin/patch'
    end
  end

  def install_method
    if PACKMAN.redhat? or PACKMAN.debian? or PACKMAN.cygwin?
      PACKMAN.os_how_to_install 'patch'
    elsif PACKMAN.mac?
      'Mac should provide patch when command line tools are installed!'
    end
  end
end
