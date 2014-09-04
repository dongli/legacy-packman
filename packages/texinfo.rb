class Texinfo < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/texinfo/texinfo-5.2.tar.gz'
  sha1 'dc54edfbb623d46fb400576b3da181f987e63516'
  version '5.2'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-install-warnings
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
