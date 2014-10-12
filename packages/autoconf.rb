class Autoconf < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.redhat_gang?
      PACKMAN::OS.installed? 'autoconf'
    elsif PACKMAN::OS.mac_gang?
      PACKMAN.does_command_exist? 'autom4te'
    end
  end

  def install_method
    if PACKMAN::OS.redhat_gang?
      PACKMAN::OS.how_to_install 'autoconf'
    elsif PACKMAN::OS.mac_gang?

    end
  end
end
