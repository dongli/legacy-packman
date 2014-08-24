class Xorg_macros < PACKMAN::Package
  # http://cgit.freedesktop.org/xorg/util/macros/
  git 'http://anongit.freedesktop.org/git/xorg/util/macros.git'
  tag 'util-macros-1.19.0'
  dirname 'xorg-macros-1.19.0'
  sha1 'cdb48b9d82e8941ceb30ab745ddd24a26a2ff0fb'
  version '1.19.0'

  skip_on :Mac_OS_X

  def install
    PACKMAN.run './autogen.sh'
    PACKMAN.run "./configure --prefix=#{PACKMAN::Package.prefix(self)}"
    PACKMAN.run 'make install'
  end
end