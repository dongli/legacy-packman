class Netcdf_cxx < PACKMAN::Package
  url 'https://github.com/Unidata/netcdf-cxx4/archive/v4.2.1.tar.gz'
  sha1 '0bb4a0807f10060f98745e789b6dc06deddf30ff'
  version '4.2.1'

  depends_on 'netcdf_c'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
    ]
    netcdf_c_prefix = PACKMAN::Package.prefix(Netcdf_c)
    envs = %W[
      PATH=#{netcdf_c_prefix}/bin:$PATH
      CPPFLAGS='-I#{netcdf_c_prefix}/include'
      LDFLAGS='-L#{netcdf_c_prefix}/lib'
    ]
    PACKMAN::Package.run './configure', *args, *envs
    PACKMAN::Package.run 'make'
    PACKMAN::Package.run 'make check'
    PACKMAN::Package.run 'make install'
  end
end