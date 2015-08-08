class Libtool < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/libtool/libtool-2.4.5.tar.xz'
  sha1 'b75650190234ed898757ec8ca033ffabbee89e7c'
  version '2.4.5'

  depends_on 'm4'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-ltdl-install
    ]
    if PACKMAN.mac?
      args << '--program-prefix=g'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
