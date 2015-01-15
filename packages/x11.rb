class X11 < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.mac_gang?
      return Dir.exist? '/usr/X11'
    elsif PACKMAN::OS.debian_gang?
      return PACKMAN::OS.installed? [
        'libx11-dev', 'xorg-dev'
      ]
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.installed? [
        'libX11-devel',
        'libXaw', 'libXaw-devel'
      ]
    elsif PACKMAN::OS.cygwin_gang?
      return PACKMAN::OS.installed? [
        'libX11-devel',
        'libXaw-devel', 'libXaw7'
      ]
    end
  end

  def install_method
    if PACKMAN::OS.mac_gang?
      return "Download Xquartz from http://xquartz.macosforge.org/landing/"
    elsif PACKMAN::OS.debian_gang?
      return PACKMAN::OS.how_to_install ['libX11-dev', 'xorg-dev']
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.how_to_install [
        'libX11-devel',
        'libXaw', 'libXaw-devel'
      ]
    elsif PACKMAN::OS.cygwin_gang?
      return PACKMAN::OS.how_to_install [
        'libX11-devel',
        'libXaw-devel', 'libXaw7'
      ]
    end
  end
end
