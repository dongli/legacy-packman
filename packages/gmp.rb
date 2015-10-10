class Gmp < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gmp/gmp-6.0.0a.tar.bz2'
  sha1 '360802e3541a3da08ab4b55268c80f799939fddc'
  version '6.0.0a'

  depends_on :m4

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 '46cdaec03e169a1d8dbcbe9631ffba180b116dee'
    version '6.0.0a'
  end

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
