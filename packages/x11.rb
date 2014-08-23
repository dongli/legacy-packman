class X11 < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    begin
      case PACKMAN::OS.distro
      when :Mac_OS_X
        return Dir.exist? '/usr/X11'
      when :Ubuntu
        PACKMAN.slim_run 'dpkg-query -l libx11-dev'
        PACKMAN.slim_run 'dpkg-query -l xorg-dev'
      when :Red_Hat_Enterprise
        PACKMAN.slim_run 'rpm -q libX11-devel'
      end
    rescue
      return false
    end
  end

  def install_method
    case PACKMAN::OS.distro
    when :Mac_OS_X
      return "Download Xquartz from http://xquartz.macosforge.org/landing/"
    when :Ubuntu
      return "sudo apt-get install libx11-dev\nsudo apt-get install xorg-dev"
    when :Red_Hat_Enterprise
      return "sudo yum install libX11-devel"
    end
  end
end