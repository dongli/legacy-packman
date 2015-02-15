class Nco < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/nco/nco-4.4.7.tar.gz'
  sha1 '5a59d237e54c197430afd7c197d9997d25b9cb38'
  version '4.4.7'

  depends_on 'flex'
  depends_on 'curl'
  depends_on 'antlr2'
  depends_on 'netcdf_c'
  depends_on 'texinfo'
  depends_on 'udunits'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-netcdf4
      --enable-dap
      --enable-ncap2
      --enable-udunits2
      NETCDF_INC=#{Netcdf_c.include}
      NETCDF_LIB=#{Netcdf_c.lib}
      NETCDF4_ROOT=#{Netcdf_c.prefix}
      NETCDF_ROOT=#{Netcdf_c.prefix}
      UDUNITS2_PATH=#{Udunits.prefix}
      ANTLR_ROOT=#{Antlr2.prefix}
      CFLAGS='-I#{Curl.include} -I#{Hdf5.include}'
      LDFLAGS='-L#{Curl.lib} -L#{Hdf5.lib}'
    ]
    if PACKMAN::OS.cygwin_gang?
      args << "LIBS='-L#{Curl.lib} -lcurl -L#{Hdf5.lib} -lhdf5 -lhdf5_hl'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
