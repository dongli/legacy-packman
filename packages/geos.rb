class Geos < PACKMAN::Package
  url 'http://download.osgeo.org/geos/geos-3.4.2.tar.bz2'
  sha1 'b8aceab04dd09f4113864f2d12015231bb318e9a'
  version '3.4.2'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end