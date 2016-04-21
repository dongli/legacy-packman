class Ghostscript < PACKMAN::Package
  url 'http://downloads.ghostscript.com/public/ghostscript-9.18.tar.gz'
  sha1 '761c9c25b9f5fe01197bd1510f527b3c1b6eb9de'
  version '9.18'

  depends_on :expat
  depends_on :jpeg
  depends_on :jbig2dec
  depends_on :libtiff
  depends_on :libpng
  depends_on :little_cms
  depends_on :djvulibre
  depends_on :fontconfig
  depends_on :freetype
  depends_on :x11

  patch :embed if PACKMAN.mac?

  attach 'fonts' do
    url 'https://downloads.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz'
    sha1 '2a7198e8178b2e7dba87cb5794da515200b568f5'
  end

  attach 'gsdjvu' do
    url 'https://downloads.sourceforge.net/project/djvu/GSDjVu/1.6/gsdjvu-1.6.tar.gz'
    sha1 'a8c5520d698d8be558a1957b4e5108cba68822ef'
  end

  def install
    PACKMAN.handle_unlinked Freetype if PACKMAN.mac?

    PACKMAN.decompress gsdjvu.package_path
    PACKMAN.work_in 'gsdjvu-1.6' do
      PACKMAN.replace 'gsdjvu.mak', { '$(GL' => '$(DEV' }
      PACKMAN.cp 'gdevdjvu.c', '../devices'
      PACKMAN.cp 'ps2utf8.ps', '../lib'
      PACKMAN.reset_env 'EXTRA_INIT_FILES', 'ps2utf8.ps'
      PACKMAN.append '../devices/contrib.mak', File.read('gsdjvu.mak')
    end


    args = %W[
      --prefix=#{prefix}
      --disable-cups
      --disable-compile-inits
      --disable-gtk
      --with-system-libtiff
    ]
    PACKMAN.append_env 'PKG_CONFIG_PATH', Libtiff.lib + '/pkgconfig', ':'
    PACKMAN.append_env 'PKG_CONFIG_PATH', Freetype.lib + '/pkgconfig', ':'
    PACKMAN.append_env 'PKG_CONFIG_PATH', PACKMAN.link_root + '/lib/pkgconfig', ':'
    PACKMAN.run 'rm -rf freetype lcms2 jpeg libpng'
    PACKMAN.run './configure', *args
    PACKMAN.replace 'Makefile', {
      /^DEVICE_DEVS17=/ => 'DEVICE_DEVS17=$(DD)djvumask.dev $(DD)djvusep.dev',
      /^EXTRALIBS=(.*)$/ => "EXTRALIBS=-L#{link_root}/lib -Wl,-rpath,#{link_root} \\1",
      /^AUXEXTRALIBS=(.*)$/ => "AUXEXTRALIBS=-L#{link_root}/lib -Wl,-rpath,#{link_root} \\1"
    }
    PACKMAN.run 'make install'
    PACKMAN.run 'make install-so'
    PACKMAN.work_in "#{share}/ghostscript" do
      PACKMAN.decompress fonts.package_path
    end
  end
end

__END__
diff --git a/base/gserrors.h b/base/gserrors.h
index 5f18081..cdebb38 100644
--- a/base/gserrors.h
+++ b/base/gserrors.h
@@ -25,7 +25,7 @@
 /* We don't use a typedef internally to avoid a lot of casting. */
 
 enum gs_error_type {
-    gs_error_ok = 0,	/* unknown error */
+    gs_error_ok = 0,
     gs_error_unknownerror = -1,	/* unknown error */
     gs_error_dictfull = -2,
     gs_error_dictstackoverflow = -3,
diff --git a/base/unix-dll.mak b/base/unix-dll.mak
index 7b67aa1..73b4fa9 100644
--- a/base/unix-dll.mak
+++ b/base/unix-dll.mak
@@ -186,6 +186,7 @@ install-so-subtarget: so-subtarget
 	ln -s $(GS_SONAME_MAJOR_MINOR) $(DESTDIR)$(libdir)/$(GS_SONAME_MAJOR)
 	$(INSTALL_DATA) $(PSSRC)iapi.h $(DESTDIR)$(gsincludedir)iapi.h
 	$(INSTALL_DATA) $(PSSRC)ierrors.h $(DESTDIR)$(gsincludedir)ierrors.h
+	$(INSTALL_DATA) $(GLSRC)gserrors.h $(DESTDIR)$(gsincludedir)gserrors.h
 	$(INSTALL_DATA) $(DEVSRC)gdevdsp.h $(DESTDIR)$(gsincludedir)gdevdsp.h
 
 soinstall:
