class Hdf_eos5 < PACKMAN::Package
  url 'ftp://edhs1.gsfc.nasa.gov/edhs/hdfeos5/previous_releases/HDF-EOS5.1.14.tar.Z'
  sha1 'e27d276dd1bef5eab77a42d2c9fa26b98026f75d'
  version '1.14'

  depends_on 'hdf5'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --with-hdf5=#{PACKMAN::Package.prefix(Hdf5)}
      --with-zlib=#{PACKMAN::Package.prefix(Zlib)}
      --with-szlib=#{PACKMAN::Package.prefix(Szip)}
      CC='#{PACKMAN::Package.prefix(Hdf4)}/bin/h5cc -Df2cFortran'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make all'
    PACKMAN.run 'make install'
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/include"
    PACKMAN.cp 'include/HE5_GctpFunc.h', "#{PACKMAN::Package.prefix(self)}/include"
    PACKMAN.cp 'include/HE5_HdfEosDef.h', "#{PACKMAN::Package.prefix(self)}/include"
    PACKMAN.cp 'include/cfortHdf.h', "#{PACKMAN::Package.prefix(self)}/include"
    # TODO: Should we copy HE5_HdfEosDef.h to HdfEosDef.h?
  end
end
