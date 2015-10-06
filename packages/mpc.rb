class Mpc < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz'
  sha1 'b8be66396c726fdc36ebb0f692ed8a8cca3bcc66'
  version '1.0.3'

  binary do
    compiled_on :Mac, '=~ 10.11'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 '798c37e8839bf346c942960ebb453c3ce33b9383'
    version '1.0.3'
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-gmp=#{Gmp.prefix}
      --with-mpfr=#{Mpfr.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
