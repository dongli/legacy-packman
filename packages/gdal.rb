class Gdal < PACKMAN::Package
  url 'http://download.osgeo.org/gdal/1.11.1/gdal-1.11.1.tar.gz'
  sha1 'e2c67481932ec9fb6ec3c0faadc004f715c4eef4'
  version '1.11.1'

  depends_on 'szip'
  depends_on 'curl'
  depends_on 'hdf4'
  depends_on 'hdf5'
  depends_on 'expat'
  depends_on 'proj'
  depends_on 'geos'
  depends_on 'jpeg'
  depends_on 'zlib'
  depends_on 'libpng'
  depends_on 'giflib'
  depends_on 'libgeotiff'
  depends_on 'libtiff'
  depends_on 'armadillo'
  depends_on 'libxml2'

  def install
    args = %W[
      --prefix=#{prefix}
      --with-static-proj4=#{Proj.prefix}
      --without-pam
      --with-gif=#{Giflib.prefix}
      --with-libtiff=#{Libtiff.prefix}
      --with-geotiff=#{Libgeotiff.prefix}
      --with-jpeg=#{Jpeg.prefix}
      --with-libz=#{Zlib.prefix}
      --with-sqlite3=no
      --with-expat=#{Expat.prefix}
      --with-curl=#{Curl.bin}
      --without-ld-shared
      --with-hdf4=#{Hdf4.prefix}
      --with-hdf5=#{Hdf5.prefix}
      --with-pg=no
      --without-grib
      --disable-shared
      --with-freexl=no
      --with-geos=#{Geos.prefix}
      --with-openjpeg=no
      --with-mysql=no
      --with-ecw=no
      --with-fgdb=no
      --with-odbc=no
      --with-xml2=#{Libxml2.prefix}
      --with-armadillo=#{Armadillo.prefix}
    ]
    if PACKMAN.mac?
      args << '--with-png=internal'
    else
      args << "--with-png=#{Libpng.prefix}"
    end
    PACKMAN.set_cppflags_and_ldflags [Szip]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make all'
    PACKMAN.run 'make install'
  end
end
