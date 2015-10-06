class Hyrax_fileout_netcdf < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/fileout_netcdf-1.2.4.tar.gz'
  sha1 'fcaa4969d5392e11db8ccf02f5f2f14b936a4af5'
  version '1.2.4'

  belongs_to 'hyrax'

  depends_on :opendap
  depends_on :hyrax_bes
  depends_on :netcdf_c

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
