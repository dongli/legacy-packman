class Pixman < PACKMAN::Package
  url 'http://cairographics.org/releases/pixman-0.32.6.tar.gz'
  sha1 '8791343cbf6d99451f4d08e8209d6ac11bf96df2'
  version '0.32.6'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-gtk
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end