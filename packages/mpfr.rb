class Mpfr < PACKMAN::Package
  url 'http://www.mpfr.org/mpfr-current/mpfr-3.1.3.tar.gz'
  sha1 'b48bec6fcc9c0458e38150778f2be85d1665aadc'
  version '3.1.3'

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
