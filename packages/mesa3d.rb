class Mesa3d < PACKMAN::Package
  label 'should_be_provided_by_system'

  def installed?
    if PACKMAN.debian?
      return PACKMAN.os_installed? [
        'libglu1-mesa', 'libglu1-mesa-dev']
    elsif PACKMAN.redhat?
      return PACKMAN.os_installed? [
        'mesa-libGL',  'mesa-libGL-devel',
        'mesa-libGLU', 'mesa-libGLU-devel',
        'mesa-libGLw', 'mesa-libGLw-devel'
      ]
    elsif PACKMAN.mac?
      return true
    end
  end

  def install_method
    if PACKMAN.debian?
      return PACKMAN.os_how_to_install [
        'libglu1-mesa', 'libglu1-mesa-dev']
    elsif PACKMAN.redhat?
      return PACKMAN.os_how_to_install [
        'mesa-libGL',  'mesa-libGL-devel',
        'mesa-libGLU', 'mesa-libGLU-devel',
        'mesa-libGLw', 'mesa-libGLw-devel'
      ]
    elsif PACKMAN.mac?
      return "Download Xquartz from http://xquartz.macosforge.org/landing/"
    end
  end
end
