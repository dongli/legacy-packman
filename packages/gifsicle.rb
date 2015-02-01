class Gifsicle < PACKMAN::Package
  url 'http://www.lcdf.org/gifsicle/gifsicle-1.86.tar.gz'
  sha1 '517e68b781594851750d7d807e25bd18b1f5dbc4'
  version '1.86'

  label 'compiler_insensitive'

  depends_on 'x11'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --enable-gifview
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end