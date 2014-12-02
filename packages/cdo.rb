class Cdo < PACKMAN::Package
  url 'https://code.zmaw.de/attachments/download/9367/cdo-1.6.6.tar.gz'
  sha1 'a324a9ab55b125aefe8b66003ac6a669dfe25bc2'
  version '1.6.6'

  depends_on 'hdf5'
  depends_on 'netcdf_c'
  depends_on 'szip'
  depends_on 'jasper'
  depends_on 'grib_api'
  depends_on 'udunits'
  depends_on 'proj'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --with-hdf5=#{PACKMAN.prefix(Hdf5)}
      --with-netcdf=#{PACKMAN.prefix(Netcdf_c)}
      --with-szlib=#{PACKMAN.prefix(Szip)}
      --with-jasper=#{PACKMAN.prefix(Jasper)}
      --with-grib_api=#{PACKMAN.prefix(Grib_api)}
      --with-udunits2=#{PACKMAN.prefix(Udunits)}
      --with-proj=#{PACKMAN.prefix(Proj)}
      --disable-dependency-tracking
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
