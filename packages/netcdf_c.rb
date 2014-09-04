class Netcdf_c < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.2.tar.gz'
  sha1 '6e1bacab02e5220954fe0328d710ebb71c071d19'
  version '4.3.2'

  depends_on 'curl'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'hdf5'

  def install
    curl_prefix = PACKMAN::Package.prefix(Curl)
    zlib_prefix = PACKMAN::Package.prefix(Zlib)
    szip_prefix = PACKMAN::Package.prefix(Szip)
    hdf5_prefix = PACKMAN::Package.prefix(Hdf5)
    PACKMAN.append_env "CFLAGS='-I#{curl_prefix}/include -I#{zlib_prefix}/include -I#{szip_prefix}/include -I#{hdf5_prefix}/include'"
    PACKMAN.append_env "LDFLAGS='-L#{curl_prefix}/lib -L#{zlib_prefix}/lib -L#{szip_prefix}/lib -L#{hdf5_prefix}/lib'"
    PACKMAN.append_env "FFLAGS=-ffree-line-length-none"
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
      --enable-netcdf4
      --disable-doxygen
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end
end
