class Ncview < PACKMAN::Package
  url 'ftp://cirrus.ucsd.edu/pub/ncview/ncview-2.1.6.tar.gz'
  sha1 'b5d9f0280d2d151a4bd330d1a4f8a015ab38197e'
  version '2.1.6'

  label :compiler_insensitive

  depends_on :x11
  depends_on :netcdf_c
  depends_on :udunits
  depends_on :libpng

  def install
    # Ignore the C compiler difference, since we may use MPI wrapper to build Netcdf_c.
    PACKMAN.replace 'configure', {
      'if test x$CC_TEST_SAME != x$NETCDF_CC_TEST_SAME; then' => 'if false; then'
    }
    args = %W[
      --prefix=#{prefix}
      --with-nc-config=#{Netcdf_c.bin}/nc-config
      --with-udunits2_incdir=#{Udunits.inc}
      --with-udunits2_libdir=#{Udunits.lib}
      --disable-dependency-tracking
    ]
    if PACKMAN.mac?
      args << '--x-includes=/usr/X11/include'
      args << '--x-libraries=/usr/X11/lib'
    else
      args << "--with-png_incdir=#{Libpng.inc}"
      args << "--with-png_libdir=#{Libpng.lib}"
    end
    if PACKMAN.cygwin?
      args << "LIBS='-L#{Curl.lib} -lcurl -L#{Hdf5.lib} -lhdf5 -lhdf5_hl'"
      PACKMAN.replace 'configure', {
        'libpng.so' => 'libpng.a',
        ' sed s/\.so//' => ' sed s/\.a//'
      }
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end

