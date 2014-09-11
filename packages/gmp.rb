class Gmp < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gmp/gmp-6.0.0a.tar.bz2'
  sha1 '360802e3541a3da08ab4b55268c80f799939fddc'
  version '6.0.0a'

  depends_on 'm4'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end