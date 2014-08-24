class Nco < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/nco/nco-4.4.2.tar.gz'
  sha1 '6253e0d3b00359e1ef2c95f0c86e940697286a10'
  version '4.4.2'

  # depends_on 'gsl'
  depends_on 'antrl2'
  depends_on 'netcdf_c'
  # depends_on 'texinfo'
  depends_on 'udunits'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --enable-netcdf4
      NETCDF_INC=#{PACKMAN::Package.prefix(Netcdf_c)}/include
      NETCDF_LIB=#{PACKMAN::Package.prefix(Netcdf_c)}/NETCDF_LIB
      NETCDF4_ROOT=#{PACKMAN::Package.prefix(Netcdf_c)}
      UDUNITS2_PATH=#{PACKMAN::Package.prefix(Udunits)}
      ANTLR_ROOT=#{PACKMAN::Package.prefix(Antlr)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end