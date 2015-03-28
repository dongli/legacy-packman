class Grib_api < PACKMAN::Package
  url 'https://software.ecmwf.int/wiki/download/attachments/3473437/grib_api-1.12.3.tar.gz'
  sha1 '2764b262c8f081fefb81112f7f7463a3a34b6e66'
  version '1.12.3'

  depends_on 'netcdf_c'
  depends_on 'jasper'
  # Openjpeg can only be download from Google Code which is blocked by our great nation!
  # depends_on 'openjpeg'

  def install
    args = %W[
      --prefix=#{prefix}
      --with-netcdf=#{Netcdf_c.prefix}
      --with-jasper=#{Jasper.prefix}
    ]
    if PACKMAN.cygwin?
      args << "LIBS='-L#{Curl.lib} -lcurl -L#{Hdf5.lib} -lhdf5 -lhdf5_hl'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
