class Arpack < PACKMAN::Package
  url 'http://forge.scilab.org/index.php/p/arpack-ng/downloads/get/arpack-ng_3.1.4.tar.gz'
  sha1 '1fb817346619b04d8fcdc958060cc0eab2c73c6f'
  version '3.1.4'

  depends_on 'openblas'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-blas='-L#{Openblas.lib} -lopenblas'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end