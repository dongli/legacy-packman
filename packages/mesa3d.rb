class Mesa3d < PACKMAN::Package
  label 'should_provided_by_system'

  skip_on :Mac_OS_X

  def installed?
    case PACKMAN::OS.distro
    when :Ubuntu
      return PACKMAN::OS.installed? [
        'libglu1-mesa', 'libglu1-mesa-dev']
    when :Red_Hat_Enterprise
      return PACKMAN::OS.installed? [
        'mesa-libGL',  'mesa-libGL-devel',
        'mesa-libGLU', 'mesa-libGLU-devel',
        'mesa-libGLw', 'mesa-libGLw-devel',
        'mesa-libOSMesa', 'mesa-libOSMesa-devel'
      ]
    end
  end

  def install_method
    case PACKMAN::OS.distro
    when :Ubuntu
      return PACKMAN::OS.how_to_install [
        'libglu1-mesa', 'libglu1-mesa-dev']
    when :Red_Hat_Enterprise
      return PACKMAN::OS.how_to_install [
        'mesa-libGL',  'mesa-libGL-devel',
        'mesa-libGLU', 'mesa-libGLU-devel',
        'mesa-libGLw', 'mesa-libGLw-devel',
        'mesa-libOSMesa', 'mesa-libOSMesa-devel'
      ]
    end
  end
end