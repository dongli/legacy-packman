class Hdf4 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF/releases/HDF4.2.10/src/hdf-4.2.10.tar.bz2'
  sha1 '5163543895728dabb536a0659b3d965d55bccf74'
  version '4.2.10'

  depends_on 'yacc'
  depends_on 'flex'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'jpeg'

  def install
    # Note: We can not enable shared and fortran simultaneously.
    # => configure:5994: error: Cannot build shared fortran libraries. Please configure with --disable-fortran flag.
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --with-zlib=#{PACKMAN.prefix(Zlib)}
      --with-jpeg=#{PACKMAN.prefix(Jpeg)}
      --with-szlib=#{PACKMAN.prefix(Szip)}
      --disable-netcdf
      --enable-fortran
      --enable-static
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
