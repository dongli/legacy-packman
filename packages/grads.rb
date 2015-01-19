class Grads < PACKMAN::Package
  url 'ftp://cola.gmu.edu/grads/2.1/grads-2.1.a2-src.tar.gz'
  sha1 '16643f7148bfeb256ac824725dfee154530a52ff'
  version '2.1.a2'

  label 'compiler_insensitive'

  depends_on 'zlib'
  depends_on 'szip'
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
    cppflags = []
    ldflags = []
    [X11, Fontconfig, Freetype, Pixman, Cairo, Zlib, Szip,
     Zlib, Jasper, Libpng, Shapelib, Grib2_c,
      Udunits, Libgd, Curl, Libxml2, Opendap].each do |lib|
      if lib == Cairo
        cppflags << "-I#{PACKMAN.prefix lib}/include/cairo"
      elsif lib == Fontconfig
        cppflags << "-I#{PACKMAN.prefix lib}/include/fontconfig"
      elsif lib == Freetype
        cppflags << "-I#{PACKMAN.prefix lib}/include/freetype2"
      elsif lib == Pixman
        cppflags << "-I#{PACKMAN.prefix lib}/include/pixman-1"
      else
        cppflags << "-I#{PACKMAN.prefix lib}/include"
      end
      ldflags << "-L#{PACKMAN.prefix lib}/lib"
    end
    PACKMAN.replace 'configure', {
      /NC_CONFIG=.*$/ => "NC_CONFIG='#{PACKMAN.prefix Netcdf}/bin/nc-config'",
      '-ludunits' => '-ludunits2',
      /(if test "\$with_shp" != "no" ; then)/ => "\\1\nga_supplib_dir=#{PACKMAN.prefix Shapelib}\n",
      /shapelib shp/ => "'/'",
      /(echo "- OPeNDAP for station data disabled"\n\s*else)/ => "\\1\nga_supplib_dir=#{PACKMAN.prefix Gadap}\n",
      /for ga_inc_name in gadap ; do/ => 'for ga_inc_name in "/" ; do',
      /(CPPFLAGS="\$CPPFLAGS )/ => "\\1#{cppflags.join(' ')} ",
      /(LDFLAGS="-L\${ga_supplib_dir}\/lib )/ => "\\1#{ldflags.join(' ')} "
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
    PACKMAN.run './configure', *args
    ['Makefile', 'src/Makefile'].each do |makefile|
      PACKMAN.replace makefile, {
        /^cairo_inc =.*$/ => "cairo_inc = -I#{PACKMAN.prefix Cairo}/include/cairo -I#{PACKMAN.prefix Freetype}/include/freetype2 -I#{PACKMAN.prefix Fontconfig}/include/fontconfig -I#{PACKMAN.prefix Libpng}/include -I#{PACKMAN.prefix Pixman}/include/pixman-1",
        /^cairo_libs =.*$/ => "cairo_libs = -L#{PACKMAN.prefix Cairo}/lib -lcairo -L#{PACKMAN.prefix X11}/lib -lXrender -L#{PACKMAN.prefix Freetype}/lib -lfreetype -L#{PACKMAN.prefix Fontconfig}/lib -lfontconfig -L#{PACKMAN.prefix Pixman}/lib -lpixman-1 -L#{PACKMAN.prefix Libpng}/lib -lpng -L#{PACKMAN.prefix Libxml2}/lib -lxml2 -L#{PACKMAN.prefix Zlib}/lib -lz",
        /^grib2_inc =.*$/ => "grib2_inc = -I#{PACKMAN.prefix Grib2_c}/include",
        /^grib2_libs =.*$/ => "grib2_libs = -L#{PACKMAN.prefix Grib2_c}/lib -lgrib2c -L#{PACKMAN.prefix Jasper}/lib -ljasper -L#{PACKMAN.prefix Libpng}/lib -lpng -L#{PACKMAN.prefix Zlib}/lib -lz",
        /^printim_inc =.*$/ => "printim_inc = -I#{PACKMAN.prefix Libgd}/include",
        /^printim_libs =.*$/ => "printim_libs = -L#{PACKMAN.prefix Libgd}/lib -lgd -L#{PACKMAN.prefix Libpng}/lib -lpng -L#{PACKMAN.prefix Zlib}/lib -lz -L#{PACKMAN.prefix Jpeg}/lib -ljpeg",
        /^shp_inc =.*$/ => "shp_inc = -I#{PACKMAN.prefix Shapelib}/include",
        /^shp_libs =.*$/ => "shp_libs = -L#{PACKMAN.prefix Shapelib}/lib -lshp",
        /^gadap_inc =.*$/ => "gadap_inc = -I#{PACKMAN.prefix Gadap}/include",
        /^dap_libs =.*$/ => "dap_libs = -L#{PACKMAN.prefix Gadap}/lib -lgadap -L#{PACKMAN.prefix Opendap}/lib -ldapclient -ldap -L#{PACKMAN.prefix Curl}/lib -lcurl -L#{PACKMAN.prefix Libxml2}/lib -lxml2 -L#{PACKMAN.prefix Zlib}/lib -lz -lpthread -lm -liconv",
        /^hdf_inc =.*$/ => "hdf_inc = -I#{PACKMAN.prefix Udunits}/include -I#{PACKMAN.prefix Hdf4}/include",
        /^hdf_libs =.*$/ => "hdf_libs = -L#{PACKMAN.prefix Hdf4}/lib -lmfhdf -ldf -L#{PACKMAN.prefix Jpeg}/lib -ljpeg -L#{PACKMAN.prefix Zlib}/lib -lz -L#{PACKMAN.prefix Szip}/lib -lsz -L#{PACKMAN.prefix Udunits}/lib -ludunits2",
        /^nc_inc =.*$/ => "nc_inc = -I#{PACKMAN.prefix Netcdf}/include",
        /^nc_libs =.*$/ => "nc_libs = -L#{PACKMAN.prefix Netcdf}/lib -lnetcdf -L#{PACKMAN.prefix Udunits}/lib -ludunits2",
        /^readline_inc =.*$/ => "readline_inc = -I#{PACKMAN.prefix Readline}/include/readline",
        /^readline_libs =.*$/ => "readline_libs = -L#{PACKMAN.prefix Readline}/lib -lreadline",
        /^LIBS = -lm  -lreadline/ => "LIBS = -lm -L#{PACKMAN.prefix Readline}/lib -lreadline"
      }
    end
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
    PACKMAN.mkdir "#{PACKMAN.prefix self}/lib"
    PACKMAN.work_in "#{PACKMAN.prefix self}/lib" do
      PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/data2.tar.gz"
    end
  end
end
