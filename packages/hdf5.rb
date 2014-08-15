class Hdf5 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.bz2'
  sha1 '712955025f03db808f000d8f4976b8df0c0d37b5'

  depends_on 'szip'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix('hdf5', '1.8.13')}
      --enable-production
      --enable-debug=no
      --disable-dependency-tracking
      --with-zlib=/usr
      --with-szlib=#{PACKMAN::Package.prefix('szip', '2.1')}
      --enable-filters=all
      --enable-static=yes
      --enable-shared=yes
    ]
  end
end
