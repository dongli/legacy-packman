class Libxml2 < PACKMAN::Package
  url 'http://xmlsoft.org/sources/libxml2-2.9.2.tar.gz'
  sha1 'f46a37ea6d869f702e03f393c376760f3cbee673'
  version '2.9.2'

  depends_on 'zlib'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --without-python
      --with-zlib=#{Zlib.prefix}
      --without-lzma
    ]
    PACKMAN.run './configure', *args
    PACKMAN.replace 'Makefile', '-no-undefined' => '' if PACKMAN.compiler('c').vendor == 'llvm'
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
