class Jasper < PACKMAN::Package
  url 'http://download.osgeo.org/gdal/jasper-1.900.1.uuid.tar.gz'
  sha1 'bbf30168ceae74d78e28039972657a90799e68d3'
  version '1.900.1'

  depends_on 'patch'
  depends_on 'jpeg'

  patch :embed

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-shared
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end

__END__
diff -uNr a/src/libjasper/jpc/jpc_dec.c b/src/libjasper/jpc/jpc_dec.c
--- a/src/libjasper/jpc/jpc_dec.c	2007-01-20 05:43:00.000000000 +0800
+++ b/src/libjasper/jpc/jpc_dec.c	2014-09-27 10:45:02.000000000 +0800
@@ -1069,12 +1069,18 @@
 	/* Apply an inverse intercomponent transform if necessary. */
 	switch (tile->cp->mctid) {
 	case JPC_MCT_RCT:
-		assert(dec->numcomps == 3);
+        if (dec->numcomps != 3 && dec->numcomps != 4) {
+            jas_eprintf("bad number of components (%d)\n", dec->numcomps);
+            return -1;
+        }
 		jpc_irct(tile->tcomps[0].data, tile->tcomps[1].data,
 		  tile->tcomps[2].data);
 		break;
 	case JPC_MCT_ICT:
-		assert(dec->numcomps == 3);
+        if (dec->numcomps != 3 && dec->numcomps != 4) {
+            jas_eprintf("bad number of components (%d)\n", dec->numcomps);
+            return -1;
+        }
 		jpc_iict(tile->tcomps[0].data, tile->tcomps[1].data,
 		  tile->tcomps[2].data);
 		break;
