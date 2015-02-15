class Hyrax_netcdf_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/netcdf_handler-3.10.4.tar.gz'
  sha1 'fd35a36b0865c1e675828669eb8543b37544355b'
  version '3.10.4'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'netcdf_c'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-netcdf=#{Netcdf_c.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
