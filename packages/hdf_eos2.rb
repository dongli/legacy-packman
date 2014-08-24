class Hdf_eos2 < PACKMAN::Package
  url 'ftp://edhs1.gsfc.nasa.gov/edhs/hdfeos/previous_releases/HDF-EOS2.18v1.00.tar.Z'
  sha1 '25c44407870eaf40fe6148a1a815981c1aabef68'
  version '2.18v1.00'

  depends_on 'hdf4'
  depends_on 'zlib'
  depends_on 'jpeg'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --with-hdf4=#{PACKMAN::Package.prefix(Hdf4)}
      --with-zlib=#{PACKMAN::Package.prefix(Zlib)}
      --with-szlib=#{PACKMAN::Package.prefix(Szip)}
      --with-jpeg=#{PACKMAN::Package.prefix(Jpeg)}
      CC=#{PACKMAN::Package.prefix(Hdf4)}/bin/h4cc
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end