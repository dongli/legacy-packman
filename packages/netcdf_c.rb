class Netcdf_c < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.2.tar.gz'
  sha1 '6e1bacab02e5220954fe0328d710ebb71c071d19'
  version '4.3.2'

  depends_on 'hdf5'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
      --enable-netcdf4
      --disable-doxygen
    ]
    szip_prefix = PACKMAN::Package.prefix(Szip)
    hdf5_prefix = PACKMAN::Package.prefix(Hdf5)
    envs = %W[
      CFLAGS='-I#{szip_prefix}/include -I#{hdf5_prefix}'
      LDFLAGS='-L#{szip_prefix}/lib -L#{hdf5_prefix}'
      LIBS='-lsz -lhdf5 -lhdf5_hl'
    ]
    PACKMAN::Package.run './configure', *args, *envs
    PACKMAN::Package.run 'make'
    PACKMAN::Package.run 'make check'
    PACKMAN::Package.run 'make install'
  end
end