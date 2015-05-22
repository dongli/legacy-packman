class Byacc < PACKMAN::Package
  url 'ftp://invisible-island.net/byacc/byacc-20141128.tgz'
  sha1 '59ea0a166b10eaec99edacc4c38fcb006c6e84d3'
  version '20141128'

  label :try_system_package_first

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end

  def installed?
    if PACKMAN.mac?
      return File.exist? '/usr/bin/yacc'
    else
      return PACKMAN.os_installed? 'byacc'
    end
  end

  def install_method
    if PACKMAN.mac?
      return 'You should install Xcode and command line tools.'
    else
      return PACKMAN.os_how_to_install 'byacc'
    end
  end
end
