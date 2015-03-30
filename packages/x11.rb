class X11 < PACKMAN::Package
  label 'should_be_provided_by_system'

  def system_prefix
    if PACKMAN.mac?
      '/usr/X11'
    elsif PACKMAN.debian? or PACKMAN.redhat?
      '/usr'
    end
  end

  def installed?
    if PACKMAN.mac?
      return Dir.exist? '/usr/X11'
    elsif PACKMAN.debian?
      return PACKMAN.os_installed? [
        'libx11-dev', 'xorg-dev'
      ]
    elsif PACKMAN.redhat?
      return PACKMAN.os_installed? [
        'libX11-devel',
        'libXaw', 'libXaw-devel',
        'libXrender', 'libXrender-devel'
      ]
    elsif PACKMAN.cygwin?
      return PACKMAN.os_installed? [
        'libX11-devel',
        'libXaw-devel', 'libXaw7'
      ]
    end
  end

  def install_method
    if PACKMAN.mac?
      return "Download Xquartz from http://xquartz.macosforge.org/landing/"
    elsif PACKMAN.debian?
      return PACKMAN.os_how_to_install ['libX11-dev', 'xorg-dev']
    elsif PACKMAN.redhat?
      return PACKMAN.os_how_to_install [
        'libX11-devel',
        'libXaw', 'libXaw-devel',
        'libXrender', 'libXrender-devel'
      ]
    elsif PACKMAN.cygwin?
      return PACKMAN.os_how_to_install [
        'libX11-devel',
        'libXaw-devel', 'libXaw7'
      ]
    end
  end
end
