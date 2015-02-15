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
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-netcdf=#{Netcdf_c.prefix}
      DAP_CFLAGS='#{`#{Opendap.bin}/dap-config --cflags`.strip}'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
