class Arpack < PACKMAN::Package
  url 'https://github.com/opencollab/arpack-ng/archive/3.2.0.tar.gz'
  sha1 '128d04d82399c4174e1b32572845055aaaafef47'
  version '3.2.0'
  filename 'arpack-3.2.0.tar.gz'

  depends_on :openblas

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-blas='-lopenblas'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
