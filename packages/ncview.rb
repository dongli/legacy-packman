class Ncview < PACKMAN::Package
  url 'ftp://cirrus.ucsd.edu/pub/ncview/ncview-2.1.2.tar.gz'
  sha1 '425b0f5d505af9c1f974903435af385582be7ae4'
  version '2.1.2'

  label 'compiler_insensitive'

  depends_on 'x11'
  depends_on 'netcdf_c'
  depends_on 'udunits'
  depends_on 'libpng'

  patch :embed

  def install
    # Ignore the C compiler difference, since we may use MPI wrapper to build Netcdf_c.
    PACKMAN.replace 'configure', {
      'if test x$CC_TEST_SAME != x$NETCDF_CC_TEST_SAME; then' => 'if false; then'
    }
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --with-nc-config=#{PACKMAN.prefix(Netcdf_c)}/bin/nc-config
      --with-udunits2_incdir=#{PACKMAN.prefix(Udunits)}/include
      --with-udunits2_libdir=#{PACKMAN.prefix(Udunits)}/lib
      --disable-dependency-tracking
    ]
    if PACKMAN::OS.mac_gang?
      args << '--x-includes=/usr/X11/include'
      args << '--x-libraries=/usr/X11/lib'
    else
      args << "--with-png_incdir=#{PACKMAN.prefix(Libpng)}/include"
      args << "--with-png_libdir=#{PACKMAN.prefix(Libpng)}/lib"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end

__END__
diff --git a/configure b/configure
index b80ae96..a650f6f 100755
--- a/configure
+++ b/configure
@@ -8672,29 +8672,6 @@ if test x$CC_TEST_SAME != x$NETCDF_CC_TEST_SAME; then
  exit -1
 fi

-#----------------------------------------------------------------------------------
-# Construct our RPATH flags.  Idea here is that we have LDFLAGS that might look,
-# for example, something like this:
-#  LIBS="-L/usr/local/lib -lnetcdf -L/home/pierce/lib -ludunits"
-# We want to convert this to -rpath flags suitable for the compiler, which would
-# have this format:
-#  "-Wl,-rpath,/usr/local/lib -Wl,-rpath,/home/pierce/lib"
-#
-# As a safety check, I only do this for the GNU compiler, as I don't know if this
-# is anything like correct syntax for other compilers.  Note that this *does* work
-# for the Intel icc compiler, but also that the icc compiler sets $ac_compiler_gnu
-# to "yes".  Go figure.
-#----------------------------------------------------------------------------------
-if test x$ac_compiler_gnu = xyes; then
- RPATH_FLAGS=""
- for word in $UDUNITS2_LDFLAGS $NETCDF_LDFLAGS; do
-   if test `expr $word : -L/` -eq 3; then
-     RPDIR=`expr substr $word 3 999`;
-     RPATH_FLAGS="$RPATH_FLAGS -Wl,-rpath,$RPDIR"
-   fi
- done
-
-fi


 ac_config_files="$ac_config_files Makefile src/Makefile"
