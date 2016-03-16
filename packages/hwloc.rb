class Hwloc < PACKMAN::Package
  url 'http://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-1.11.2.tar.bz2'
  sha1 '3d68de060808f04349538be4e63cde501cd53b0a'
  version '1.11.2'

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --without-x
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
