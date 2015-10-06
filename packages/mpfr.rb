class Mpfr < PACKMAN::Package
  url 'http://www.mpfr.org/mpfr-current/mpfr-3.1.3.tar.gz'
  sha1 'b48bec6fcc9c0458e38150778f2be85d1665aadc'
  version '3.1.3'

  binary do
    compiled_on :Mac, '=~ 10.11'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 '82d8468caa7b6908864a8da82ef99fb116469342'
    version '3.1.3'
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
