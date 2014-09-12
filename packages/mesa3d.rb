class Mesa3d < PACKMAN::Package
  label 'should_provided_by_system'

  def installed?
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.installed? [
        'libglu1-mesa', 'libglu1-mesa-dev']
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.installed? [
        'mesa-libGL',  'mesa-libGL-devel',
        'mesa-libGLU', 'mesa-libGLU-devel',
        'mesa-libGLw', 'mesa-libGLw-devel'
      ]
    elsif PACKMAN::OS.mac_gang?
      return true
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.how_to_install [
        'libglu1-mesa', 'libglu1-mesa-dev']
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.how_to_install [
        'mesa-libGL',  'mesa-libGL-devel',
        'mesa-libGLU', 'mesa-libGLU-devel',
        'mesa-libGLw', 'mesa-libGLw-devel'
      ]
    elsif PACKMAN::OS.mac_gang?
      return "Download Xquartz from http://xquartz.macosforge.org/landing/"
    end
  end
end
