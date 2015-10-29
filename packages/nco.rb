class Nco < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/nco/nco-4.5.2.tar.gz'
  sha1 'bb87332494c39aeffe446ab4a9b2500c096fd9fe'
  version '4.5.2'

  depends_on :flex
  depends_on :bison
  depends_on :curl
  depends_on :antlr2
  depends_on :netcdf_c
  depends_on :texinfo
  depends_on :expat
  depends_on :udunits
  depends_on :gsl

  def install
    PACKMAN.handle_unlinked Libressl
    args = %W[
      --prefix=#{prefix}
      --enable-netcdf4
      --enable-dap
      --enable-ncap2
      --enable-udunits2
      --enable-optimize-custom
      NETCDF_INC=#{Netcdf_c.include}
      NETCDF_LIB=#{Netcdf_c.lib}
      NETCDF4_ROOT=#{Netcdf_c.prefix}
      NETCDF_ROOT=#{Netcdf_c.prefix}
      UDUNITS2_PATH=#{Udunits.prefix}
      ANTLR_ROOT=#{Antlr2.prefix}
    ]
    if PACKMAN.cygwin?
      args << "LIBS='-lcurl -lhdf5 -lhdf5_hl'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
