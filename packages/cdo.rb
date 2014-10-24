class Cdo < PACKMAN::Package
  url 'https://code.zmaw.de/attachments/download/8376/cdo-1.6.4.tar.gz'
  sha1 'a324a9ab55b125aefe8b66003ac6a669dfe25bc2'
  version '1.6.4'

  depends_on 'hdf5'
  depends_on 'netcdf_c'
  depends_on 'szip'
  depends_on 'jasper'
  depends_on 'grib_api'

  label 'compiler_insensitive'

  patch :embed

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --with-hdf5=#{PACKMAN.prefix(Hdf5)}
      --with-netcdf=#{PACKMAN.prefix(Netcdf_c)}
      --with-szlib=#{PACKMAN.prefix(Szip)}
      --with-jasper=#{PACKMAN.prefix(Jasper)}
      --with-grib_api=#{PACKMAN.prefix(Grib_api)}
      --disable-dependency-tracking
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end

__END__
diff -uNr a/src/remap_distwgt_scrip.c b/src/remap_distwgt_scrip.c
--- a/src/remap_distwgt_scrip.c 2014-06-26 19:21:48.000000000 +0800
+++ b/src/remap_distwgt_scrip.c 2014-09-27 11:07:20.000000000 +0800
@@ -297,10 +297,11 @@
   double *dist = (double*) malloc(ndist*sizeof(double));
   int    *adds = (int*) malloc(ndist*sizeof(int));

+  j = 0;
 #if defined(_OPENMP) && _OPENMP >= OPENMP4
 #pragma omp simd
 #endif
-  for ( j = 0, i = 0; i < ndist; ++i )
+  for ( i = 0; i < ndist; ++i )
     {
       nadd = min_add+i;
       /* Find distance to this point */
