class Gdal < PACKMAN::Package
  url 'ftp://ftp.remotesensing.org/gdal/1.10.1/gdal-1.10.1.tar.gz'
  sha1 'b4df76e2c0854625d2bedce70cc1eaf4205594ae'
  version '1.10.1'

  depends_on 'proj'
  depends_on 'jpeg'
  depends_on 'zlib'
  depends_on 'libpng'

  def install
    args = %W[
      --prefix=#{prefix}
      --with-static-proj4=#{Proj.prefix}
      --without-pam 
      --with-gif=internal
      --with-libtiff=internal 
      --with-geotiff=internal
      --with-jpeg=#{Jpeg.prefix}
      --with-libz=#{Zlib.prefix}
      --with-sqlite3=no
      --with-expat=no
      --with-curl=no
      --without-ld-shared 
      --with-hdf4=no
      --with-hdf5=no
      --with-pg=no
      --without-grib
      --disable-shared
      --with-freexl=no
      --with-geos=no
      --with-openjpeg=no
      --with-mysql=no 
      --with-ecw=no
      --with-fdgb=no
      --with-odbc=no
      --with-xml2=no
    ]
    if PACKMAN.mac?
      args << '--with-png=internal'
    else
      args << "--with-png=#{Libpng.prefix}"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make all'
    PACKMAN.run 'make install'
  end
end