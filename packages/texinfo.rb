class Texinfo < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/texinfo/texinfo-6.0.tar.gz'
  sha1 '110d45256c4219c88dc2fdb8c9c1a20749e4e7c5'
  version '6.0'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-install-warnings
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
