class Nco < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/nco/nco-4.4.5.tar.gz'
  sha1 'e210fe735b6a746a08631c23654dabd45547f6c5'
  version '4.4.5'

  depends_on 'curl'
  depends_on 'antlr2'
  depends_on 'netcdf_c'
  depends_on 'texinfo'
  depends_on 'udunits'

  def install
    curl = PACKMAN::Package.prefix(Curl)
    PACKMAN.append_env "CFLAGS='-I#{curl}/include'"
    PACKMAN.append_env "LDFLAGS='-L#{curl}/lib -Wl,-rpath,#{PACKMAN::Package.prefix(Gcc)}/lib64'"
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --enable-netcdf4
      NETCDF_INC=#{PACKMAN::Package.prefix(Netcdf_c)}/include
      NETCDF_LIB=#{PACKMAN::Package.prefix(Netcdf_c)}/lib
      NETCDF4_ROOT=#{PACKMAN::Package.prefix(Netcdf_c)}
      NETCDF_ROOT=#{PACKMAN::Package.prefix(Netcdf_c)}
      UDUNITS2_PATH=#{PACKMAN::Package.prefix(Udunits)}
      ANTLR_ROOT=#{PACKMAN::Package.prefix(Antlr2)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end
end
