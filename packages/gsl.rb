class Gsl < PACKMAN::Package
  url 'ftp://ftp.gnu.org/gnu/gsl/gsl-1.16.tar.gz'
  sha1 '210af9366485f149140973700d90dc93a4b6213e'
  version '1.16'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end