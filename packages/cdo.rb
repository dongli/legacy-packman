class Cdo < PACKMAN::Package
  url 'https://code.zmaw.de/attachments/download/10030/cdo-1.6.8.tar.gz'
  sha1 'e3a045c2980a0d133c2a84afd30c453574fdbf86'
  version '1.6.8'

  history_version '1.6.3' do
    url 'https://code.zmaw.de/attachments/download/7220/cdo-1.6.3.tar.gz'
    sha1 '9aa9f2227247eee6e5a0d949f5189f9a0ce4f2f1'
  end

  depends_on 'hdf5'
  depends_on 'netcdf'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'jasper'
  depends_on 'grib_api'
  depends_on 'udunits'
  depends_on 'proj'
  depends_on 'libxml2'

  label :compiler_insensitive

  def install
    args = %W[
      --prefix=#{prefix}
      --with-hdf5=#{Hdf5.prefix}
      --with-netcdf=#{Netcdf.prefix}
      --with-zlib=#{Zlib.prefix}
      --with-szlib=#{Szip.prefix}
      --with-jasper=#{Jasper.prefix}
      --with-grib_api=#{Grib_api.prefix}
      --with-udunits2=#{Udunits.prefix}
      --with-proj=#{Proj.prefix}
      --with-libxml2=#{Libxml2.prefix}
      --disable-dependency-tracking
      --disable-debug
    ]
    if PACKMAN.cygwin?
      args << "LIBS='-L#{Udunits.lib} -lexpat -L#{Curl.lib} -lcurl -ludunits2 -L#{Grib_api.lib} -lgrib_api'"
    else
      args << "LIBS='-L#{Udunits.lib} -lexpat'"
    end
    args << "CFLAGS='-fp-model source'" if PACKMAN.compiler('c').vendor == 'intel'
    PACKMAN.run './configure', *args
    if PACKMAN.cygwin?
      PACKMAN.run "make LIBS='-L#{Udunits.lib} -ludunits2 -lexpat -L#{Proj.lib} -lproj -L#{Grib_api.lib} -lgrib_api -L#{Netcdf.lib} -lnetcdf'"
    else
      PACKMAN.run 'make -j2'
    end
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
