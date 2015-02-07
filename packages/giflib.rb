class Giflib < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/giflib/giflib-4.x/giflib-4.1.6/giflib-4.1.6.tar.bz2'
  sha1 '22680f604ec92065f04caf00b1c180ba74fb8562'
  version '4.1.6'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-debug
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end