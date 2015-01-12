class Djvulibre < PACKMAN::Package
  url 'http://ftp.de.debian.org/debian/pool/main/d/djvulibre/djvulibre_3.5.25.4.orig.tar.gz'
  sha1 'c7044201703f30df0f1732c54c6544467412811d'
  version '3.5.25.4'

  if PACKMAN::OS.distro == :Mac_OS_X
    patch :embed
  end

  depends_on 'jpeg'
  depends_on 'libtiff'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-desktopfiles
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end

__END__
--- a/libdjvu/atomic.h
+++ b/libdjvu/atomic.h
@@ -122,7 +122,7 @@
   static inline int atomicDecrement(int volatile *var) {
     int ov; __asm__ __volatile__ ("lock; xaddl %0, %1"
          : "=r" (ov), "=m" (*var) : "0" (-1), "m" (*var) : "cc" );
-    return ov + 1;
+    return ov - 1;
   }
   static inline int atomicExchange(int volatile *var, int nv) {
     int ov; __asm__ __volatile__ ("xchgl %0, %1"
