class Grads < PACKMAN::Package
  url 'ftp://cola.gmu.edu/grads/2.1/grads-2.1.a2-src.tar.gz'
  sha1 '16643f7148bfeb256ac824725dfee154530a52ff'
  version '2.1.a2'

  label :compiler_insensitive

  depends_on :zlib
  depends_on :szip
  depends_on :libiconv
  depends_on :readline
  depends_on :cairo
  depends_on :grib2_c
  depends_on :hdf4
  depends_on :hdf5
  depends_on :netcdf
  depends_on :opendap
  depends_on :libgeotiff
  depends_on :shapelib
  depends_on :udunits
  depends_on :libgd
  depends_on :curl
  depends_on :libxml2
  depends_on :gadap

  attach 'data' do
    url 'ftp://cola.gmu.edu/grads/data2.tar.gz'
    sha1 'e1cd5f9c4fe8d6ed344a29ee00413aeb6323b7cd'
  end

  def install
    PACKMAN.replace 'configure', {
      /NC_CONFIG=.*$/ => "NC_CONFIG='#{Netcdf.bin}/nc-config'",
      'png12' => 'png',
      'png15' => 'png',
      '-ludunits' => '-ludunits2 -lexpat',
      '<fontconfig.h>' => '<fontconfig/fontconfig.h>',
      /(if test "\$with_shp" != "no" ; then)/ => "\\1\nga_supplib_dir=#{Shapelib.prefix}\n",
      /shapelib shp/ => "'/'",
      /(echo "- OPeNDAP for station data disabled"\n\s*else)/ => "\\1\nga_supplib_dir=#{Gadap.prefix}\n",
      /for ga_inc_name in gadap ; do/ => 'for ga_inc_name in "/" ; do',
      /(CPPFLAGS="\$CPPFLAGS )/ => "\\1#{PACKMAN.cppflags} ",
      /(LDFLAGS="-L\${ga_supplib_dir}\/lib )/ => "\\1#{PACKMAN.ldflags} ",
      /LDFLAGS=\$ga_saved_ldflags/ => "LDFLAGS=\"$ga_saved_ldflags #{PACKMAN.ldflags}\"",
      /(HDF4_LDFLAGS="-L\$HDF4_PATH_LIBDIR)/ => "\\1 -L#{Szip.lib}"
    }
    PACKMAN.replace 'src/gxC.c', '<fontconfig.h>' => '<fontconfig/fontconfig.h>'
    PACKMAN.replace 'src/gacfg.c', '<fontconfig.h>' => '<fontconfig/fontconfig.h>'
    args = %W[
      --prefix=#{prefix}
      --with-readline=#{Readline_.prefix}
      --with-printim
      --with-cairo=#{Cairo.prefix}
      --with-sdf
      --with-shp=#{Shapelib.prefix}
      --with-geotiff=#{Libgeotiff.prefix}
      --with-hdf4=#{Hdf4.prefix}
      --with-hdf5=#{Hdf5.prefix}
      --with-netcdf=#{Netcdf.prefix}
      --with-gadap=#{Gadap.prefix}
    ]
    PACKMAN.run './configure', *args
    ['Makefile', 'src/Makefile'].each do |makefile|
      PACKMAN.replace makefile, {
        /^LDFLAGS =.*$/ => "LDFLAGS =",
        /^cairo_inc =.*$/ => "cairo_inc = -I#{Cairo.include}/cairo -I#{Freetype.include}/freetype2 -I#{Fontconfig.include} -I#{Libpng.include} -I#{Pixman.include}/pixman-1",
        /^cairo_libs =.*$/ => "cairo_libs = -L#{Cairo.lib} -lcairo -L#{X11.lib} -lXrender -L#{Freetype.lib} -lfreetype -L#{Fontconfig.lib} -lfontconfig -L#{Pixman.lib} -lpixman-1 -L#{Libpng.lib} -lpng -L#{Libxml2.lib} -lxml2 -L#{Zlib.lib} -lz",
        /^grib2_inc =.*$/ => "grib2_inc = -I#{Grib2_c.include}",
        /^grib2_libs =.*$/ => "grib2_libs = -L#{Grib2_c.lib} -lgrib2c -L#{Jasper.lib} -ljasper -L#{Libpng.lib} -lpng -L#{Zlib.lib} -lz",
        /^geotiff_inc =.*$/ => "geotiff_inc = -I#{Libtiff.include} -I#{Libgeotiff.include}",
        /^geotiff_libs =.*$/ => "geotiff_libs = -L#{Libtiff.lib} -ltiff -L#{Libgeotiff.lib} -lgeotiff",
        /^printim_inc =.*$/ => "printim_inc = -I#{Libgd.include}",
        /^printim_libs =.*$/ => "printim_libs = -L#{Libgd.lib} -lgd -L#{Libpng.lib} -lpng -L#{Zlib.lib} -lz -L#{Jpeg.lib} -ljpeg",
        /^shp_inc =.*$/ => "shp_inc = -I#{Shapelib.include}",
        /^shp_libs =.*$/ => "shp_libs = -L#{Shapelib.lib} -lshp",
        /^gadap_inc =.*$/ => "gadap_inc = -I#{Gadap.include}",
        /^dap_libs =.*$/ => "dap_libs = -L#{Gadap.lib} -lgadap -L#{Opendap.lib} -ldapclient -ldap -L#{Curl.lib} -lcurl -L#{Libxml2.lib} -lxml2 -L#{Zlib.lib} -lz -lpthread -lm -L#{Libiconv.lib} -liconv",
        /^hdf5_inc =.*$/ => "hdf5_inc = -I#{Hdf5.include}",
        /^hdf5_libs =.*$/ => "hdf5_libs = -L#{Hdf5.lib} -lhdf5 -L#{Jpeg.lib} -ljpeg -L#{Zlib.lib} -lz -L#{Szip.lib} -lsz",
        /^hdf_inc =.*$/ => "hdf_inc = -I#{Udunits.include} -I#{Hdf4.include}",
        /^hdf_libs =.*$/ => "hdf_libs = -L#{Hdf4.lib} -lmfhdf -ldf -L#{Jpeg.lib} -ljpeg -L#{Zlib.lib} -lz -L#{Szip.lib} -lsz -L#{Udunits.lib} -ludunits2",
        /^nc_inc =.*$/ => "nc_inc = -I#{Netcdf.include}",
        /^nc_libs =.*$/ => "nc_libs = -L#{Netcdf.lib} -lnetcdf -L#{Udunits.lib} -ludunits2",
        /^readline_inc =.*$/ => "readline_inc = -I#{Readline_.include}",
        /^readline_libs =.*$/ => "readline_libs = -L#{Readline_.lib} -lreadline -L#{Ncurses.lib} -lncurses",
        /^LIBS = -lm  -lreadline/ => "LIBS = -lm -L#{Readline_.lib} -lreadline -L#{Ncurses.lib} -lncurses"
      }
    end
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
    PACKMAN.mkdir "#{lib}"
    PACKMAN.work_in "#{lib}" do
      PACKMAN.decompress data.package_path
    end
  end
end
