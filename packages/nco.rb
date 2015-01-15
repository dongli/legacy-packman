class Nco < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/nco/nco-4.4.5.tar.gz'
  sha1 'e210fe735b6a746a08631c23654dabd45547f6c5'
  version '4.4.5'

  depends_on 'flex'
  depends_on 'curl'
  depends_on 'antlr2'
  depends_on 'netcdf_c'
  depends_on 'texinfo'
  depends_on 'udunits'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --enable-netcdf4
      --enable-dap
      --enable-ncap2
      --enable-udunits2
      NETCDF_INC=#{PACKMAN.prefix(Netcdf_c)}/include
      NETCDF_LIB=#{PACKMAN.prefix(Netcdf_c)}/lib
      NETCDF4_ROOT=#{PACKMAN.prefix(Netcdf_c)}
      NETCDF_ROOT=#{PACKMAN.prefix(Netcdf_c)}
      UDUNITS2_PATH=#{PACKMAN.prefix(Udunits)}
      ANTLR_ROOT=#{PACKMAN.prefix(Antlr2)}
      CFLAGS='-I#{PACKMAN.prefix(Curl)}/include -I#{PACKMAN.prefix(Hdf5)}/include'
      LDFLAGS='-L#{PACKMAN.prefix(Curl)}/lib -L#{PACKMAN.prefix(Hdf5)}/lib'
    ]
    if PACKMAN::OS.cygwin_gang?
      args << "LIBS='-L#{PACKMAN.prefix Curl}/lib -lcurl -L#{PACKMAN.prefix Hdf5}/lib -lhdf5 -lhdf5_hl'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
