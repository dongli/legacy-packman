class Grads < PACKMAN::Package
  url 'ftp://cola.gmu.edu/grads/2.1/grads-2.1.a2-src.tar.gz'
  sha1 '16643f7148bfeb256ac824725dfee154530a52ff'
  version '2.1.a2'

  depends_on 'readline'
  depends_on 'cairo'
  depends_on 'grib2_c'
  depends_on 'hdf4'
  depends_on 'hdf5'
  depends_on 'netcdf'
  depends_on 'opendap'
  depends_on 'libgeotiff'
  depends_on 'shapelib'
  depends_on 'udunits'
  depends_on 'libgd'
  depends_on 'curl'
  depends_on 'libxml2'
  depends_on 'gadap'

  attach do
    url 'ftp://cola.gmu.edu/grads/data2.tar.gz'
    sha1 'e1cd5f9c4fe8d6ed344a29ee00413aeb6323b7cd'
  end

  def install
    PACKMAN.replace 'configure', {
      /NC_CONFIG=.*$/ => "NC_CONFIG='#{PACKMAN.prefix Netcdf}/bin/nc-config'",
      '-lpng12' => '-lpng',
      '-ludunits' => '-ludunits2'
    }
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --with-readline=#{PACKMAN.prefix Readline}
      --with-printim
      --with-cairo=#{PACKMAN.prefix Cairo}
      --with-sdf=HDF4,HDF5,NetCDF,OPeNDAP
      --with-shp=#{PACKMAN.prefix Shapelib}
      --with-geotiff=#{PACKMAN.prefix Libgeotiff}
      --with-hdf4=#{PACKMAN.prefix Hdf4}
      --with-hdf5=#{PACKMAN.prefix Hdf5}
      --with-netcdf=#{PACKMAN.prefix Netcdf}
      --with-gadap=#{PACKMAN.prefix Gadap}
    ]
    cppflags = []
    ldflags = []
    [Jasper, Libpng, Grib2_c, Udunits, Libgd, Curl, Libxml2].each do |lib|
      cppflags << "-I#{PACKMAN.prefix lib}/include"
      ldflags << "-L#{PACKMAN.prefix lib}/lib"
    end
    args << "CPPFLAGS='#{cppflags.join(' ')}'"
    args << "LDFLAGS='#{ldflags.join(' ')}'"
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
