class Mpfr < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/mpfr/mpfr-3.1.2.tar.bz2'
  sha1 '46d5a11a59a4e31f74f73dd70c5d57a59de2d0b4'
  version '3.1.2'

  patch do
    # latest update: 2014-12-04
    url 'http://www.mpfr.org/mpfr-current/allpatches'
    sha1 '26b8a0f352998c1e54a89520d36c8c4783e41962'
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-gmp=#{Gmp.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
