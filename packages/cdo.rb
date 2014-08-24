class Cdo < PACKMAN::Package
  url 'https://code.zmaw.de/attachments/download/7220/cdo-1.6.3.tar.gz'
  sha1 '9aa9f2227247eee6e5a0d949f5189f9a0ce4f2f1'
  version '1.6.3'

  depends_on 'hdf5'
  depends_on 'netcdf_c'
  depends_on 'szip'
  depends_on 'jasper'
  depends_on 'grib_api'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --with-hdf5=#{PACKMAN::Package.prefix(Hdf5)}
      --with-netcdf=#{PACKMAN::Package.prefix(Netcdf_c)}
      --with-szlib=#{PACKMAN::Package.prefix(Szip)}
      --with-jasper=#{PACKMAN::Package.prefix(Jasper)}
      --with-grib_api=#{PACKMAN::Package.prefix(Grib_api)}
      --disable-dependency-tracking
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end