class Netcdf_c < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.2.tar.gz'
  sha1 '6e1bacab02e5220954fe0328d710ebb71c071d19'
  version '4.3.2'

  depends_on 'curl'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'hdf5'

  def install
    curl = PACKMAN::Package.prefix(Curl)
    zlib = PACKMAN::Package.prefix(Zlib)
    szip = PACKMAN::Package.prefix(Szip)
    hdf5 = PACKMAN::Package.prefix(Hdf5)
    PACKMAN.append_env "CFLAGS='-I#{curl}/include -I#{zlib}/include -I#{szip}/include -I#{hdf5}/include'"
    PACKMAN.append_env "LDFLAGS='-L#{curl}/lib -L#{zlib}/lib -L#{szip}/lib -L#{hdf5}/lib'"
    PACKMAN.append_env "FFLAGS=-ffree-line-length-none"
    # NOTE: OpenDAP support should be supported in default, but I still add
    #       '--enable-dap' explicitly for reminding.
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
      --enable-netcdf4
      --enable-dap
      --disable-doxygen
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end
end
