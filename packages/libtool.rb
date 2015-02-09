class Libtool < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/libtool/libtool-2.4.5.tar.xz'
  sha1 'b75650190234ed898757ec8ca033ffabbee89e7c'
  version '2.4.5'

  skip_on :Mac_OS_X

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --enable-ltdl-install
    ]
    if PACKMAN::OS.distro == :Mac_OS_X
      args << '--program-prefix=g'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
