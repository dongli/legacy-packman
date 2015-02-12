class Cdo < PACKMAN::Package
  url 'https://code.zmaw.de/attachments/download/9367/cdo-1.6.6.tar.gz'
  sha1 'ef2176164bf166c8d5e7a3bfc5163b642312eeb2'
  version '1.6.6'

  depends_on 'hdf5'
  depends_on 'netcdf'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'jasper'
  depends_on 'grib_api'
  depends_on 'udunits'
  depends_on 'proj'
  depends_on 'libxml2'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --with-hdf5=#{PACKMAN.prefix Hdf5}
      --with-netcdf=#{PACKMAN.prefix Netcdf}
      --with-zlib=#{PACKMAN.prefix Zlib}
      --with-szlib=#{PACKMAN.prefix Szip}
      --with-jasper=#{PACKMAN.prefix Jasper}
      --with-grib_api=#{PACKMAN.prefix Grib_api}
      --with-udunits2=#{PACKMAN.prefix Udunits}
      --with-proj=#{PACKMAN.prefix Proj}
      --with-libxml2=#{PACKMAN.prefix Libxml2}
      --disable-dependency-tracking
      --disable-debug
    ]
    if PACKMAN::OS.cygwin_gang?
      args << "LIBS='-L#{PACKMAN.prefix(Udunits)}/lib -lexpat -L#{PACKMAN.prefix Curl}/lib -lcurl -ludunits2'"
      # Replace 'sqrtl' to 'sqrt'.
      PACKMAN.replace 'src/clipping/intersection.c', 'sqrtl' => 'sqrt'
    else
      args << "LIBS='-L#{PACKMAN.prefix(Udunits)}/lib -lexpat'"
    end
    PACKMAN.run './configure', *args
    if PACKMAN::OS.cygwin_gang?
      PACKMAN.run "make LIBS='-L#{PACKMAN.prefix Udunits}/lib -ludunits2 -lexpat -L#{PACKMAN.prefix Proj}/lib -lproj -L#{PACKMAN.prefix Grib_api}/lib -lgrib_api -L#{PACKMAN.prefix Netcdf}/lib -lnetcdf'"
      PACKMAN.caveat <<-EOT.gsub(/^\s+/, '')
        The checking codes for remapping with nearest neighbor method will fail
        in Cygwin, so 'make check' is skipped.
      EOT
    else
      PACKMAN.run 'make -j2'
      PACKMAN.run 'make check' if not skip_test?
    end
    PACKMAN.run 'make install'
  end
end
