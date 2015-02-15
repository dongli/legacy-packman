class Lzlib < PACKMAN::Package
  url 'http://download.savannah.gnu.org/releases/lzip/lzlib/lzlib-1.6.tar.gz'
  sha1 '4a24e4d17df3fd90f53866ace922c831f26600f6'
  version '1.6'

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
