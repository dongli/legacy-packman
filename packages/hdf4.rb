class Hdf4 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/hdf-4.2.11.tar.bz2'
  sha1 '3b98d9ef6ff1fbc569e53432bddc14c148da8274'
  version '4.2.11'

  depends_on 'yacc'
  depends_on 'flex'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'jpeg'

  def install
    # Note: We can not enable shared and fortran simultaneously.
    # => configure:5994: error: Cannot build shared fortran libraries. Please configure with --disable-fortran flag.
    args = %W[
      --prefix=#{prefix}
      --with-zlib=#{Zlib.prefix}
      --with-jpeg=#{Jpeg.prefix}
      --with-szlib=#{Szip.prefix}
      --disable-netcdf
      --enable-fortran
      --enable-static
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
