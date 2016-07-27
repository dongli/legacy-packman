class Hdf4 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/hdf-4.2.12.tar.bz2'
  sha1 'a2cd020250f40850bfd26b97d5fdec7f24746e74'
  version '4.2.12'

  depends_on :byacc
  depends_on :flex
  depends_on :zlib
  depends_on :szip
  depends_on :jpeg

  def install
    # Note: We can not enable shared and fortran simultaneously.
    # => configure:5994: error: Cannot build shared fortran libraries. Please configure with --disable-fortran flag.
    args = %W[
      --prefix=#{prefix}
      --with-zlib=#{Zlib_.prefix}
      --with-jpeg=#{Jpeg.prefix}
      --with-szlib=#{Szip.prefix}
      --disable-netcdf
      --enable-fortran
      --enable-static
    ]
    args << '--disable-fortran' if not PACKMAN.has_compiler? :fortran, :not_exit
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
