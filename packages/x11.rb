class X11 < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    case PACKMAN::OS.distro
    when :Mac_OS_X
      return Dir.exist? '/usr/X11'
    when :Ubuntu
      return PACKMAN::OS.installed? ['libx11-dev', 'xorg-dev']
    when :Red_Hat_Enterprise
      return PACKMAN::OS.installed? ['libX11-devel']
    end
  end

  def install_method
    case PACKMAN::OS.distro
    when :Mac_OS_X
      return "Download Xquartz from http://xquartz.macosforge.org/landing/"
    when :Ubuntu
      return PACKMAN::OS.how_to_install ['libX11-dev', 'xorg-dev']
    when :Red_Hat_Enterprise
      return PACKMAN::OS.how_to_install ['libX11-devel']
    end
  end
end