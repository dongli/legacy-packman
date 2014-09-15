class Mpfr < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/mpfr/mpfr-3.1.2.tar.bz2'
  sha1 '46d5a11a59a4e31f74f73dd70c5d57a59de2d0b4'
  version '3.1.2'

  patch do
    url 'http://www.mpfr.org/mpfr-current/allpatches'
    sha1 'd288266ecc33ece2f0f253e7c2e8923d70ad9c37'
  end

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --with-gmp=#{PACKMAN::Package.prefix(Gmp)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end
