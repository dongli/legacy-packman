class Hyrax_fileout_netcdf < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/fileout_netcdf-1.2.2.tar.gz'
  sha1 'a50808bcb0374430d9b4b7ba4310acce01305a42'
  version '1.2.2'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'netcdf_c'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --with-netcdf=#{PACKMAN.prefix(Netcdf_c)}
      DAP_CFLAGS='#{`#{PACKMAN.prefix(Opendap)}/bin/dap-config --cflags`.strip}'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end
