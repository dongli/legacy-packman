class Ghostscript < PACKMAN::Package
  url 'http://downloads.ghostscript.com/public/ghostscript-9.15.tar.gz'
  sha1 'f53bcc47e912c7bffc2ced62ed9311376fb18bab'
  version '9.15'

  depends_on 'expat'
  depends_on 'jpeg'
  depends_on 'jbig2dec'
  depends_on 'libtiff'
  depends_on 'libpng'
  depends_on 'little_cms'
  depends_on 'djvulibre' # TODO: Does ghostscript need it?
  depends_on 'fontconfig'
  depends_on 'freetype'
  depends_on 'x11'

  if PACKMAN::OS.distro == :Mac_OS_X
    patch :embed
  end

  attach 'fonts' do
    url 'https://downloads.sourceforge.net/project/gs-fonts/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz'
    sha1 '2a7198e8178b2e7dba87cb5794da515200b568f5'
  end

  attach 'gsdjvu' do
    url 'https://downloads.sourceforge.net/project/djvu/GSDjVu/1.6/gsdjvu-1.6.tar.gz'
    sha1 'a8c5520d698d8be558a1957b4e5108cba68822ef'
  end

  def install
    PACKMAN.decompress gsdjvu.package_path
    PACKMAN.work_in './gsdjvu-1.6' do
      PACKMAN.cp 'gdevdjvu.c', '../base'
      PACKMAN.cp 'ps2utf8.ps', '../lib'
      PACKMAN.append '../devices/contrib.mak', File.read('gsdjvu.mak')
    end
    PACKMAN.replace 'configure.ac', /ZLIBDIR=src/ => 'ZLIBDIR=$includedir'
    PACKMAN.replace 'configure', /ZLIBDIR=src/ => 'ZLIBDIR=$includedir'
    ['expat', 'freetype', 'lcms', 'tiff', 'tiff-config', 'lcms2', 'jpeg',
     'jpegxr', 'openjpeg', 'jbig2dec', 'libpng', 'zlib'].each { |x| PACKMAN.rm x }
    args = %W[
      --prefix=#{prefix}
      --disable-cups
      --disable-compile-inits
      --disable-gtk
    ]
    PACKMAN.set_cppflags_and_ldflags [Expat, Jpeg, Jbig2dec, Libtiff, Libpng, Little_cms, Fontconfig, Freetype]
    PACKMAN.run './configure', *args
    PACKMAN.replace 'Makefile', {
      /^DEVICE_DEVS17=/ => 'DEVICE_DEVS17=$(DD)djvumask.dev $(DD)djvusep.dev'
    }
    PACKMAN.run 'make install'
    PACKMAN.run 'make install-so'
    PACKMAN.work_in "#{share}/ghostscript" do
      PACKMAN.decompress fonts.package_path
    end
  end
end

__END__
diff --git a/base/unix-dll.mak b/base/unix-dll.mak
index ae2d7d8..4f4daed 100644
--- a/base/unix-dll.mak
+++ b/base/unix-dll.mak
@@ -64,12 +64,12 @@ GS_SONAME_MAJOR_MINOR=$(GS_SONAME_BASE)$(GS_SOEXT)$(SO_LIB_VERSION_SEPARATOR)$(G
 
 
 # MacOS X
-#GS_SOEXT=dylib
-#GS_SONAME=$(GS_SONAME_BASE).$(GS_SOEXT)
-#GS_SONAME_MAJOR=$(GS_SONAME_BASE).$(GS_VERSION_MAJOR).$(GS_SOEXT)
-#GS_SONAME_MAJOR_MINOR=$(GS_SONAME_BASE).$(GS_VERSION_MAJOR).$(GS_VERSION_MINOR).$(GS_SOEXT)
+GS_SOEXT=dylib
+GS_SONAME=$(GS_SONAME_BASE).$(GS_SOEXT)
+GS_SONAME_MAJOR=$(GS_SONAME_BASE).$(GS_VERSION_MAJOR).$(GS_SOEXT)
+GS_SONAME_MAJOR_MINOR=$(GS_SONAME_BASE).$(GS_VERSION_MAJOR).$(GS_VERSION_MINOR).$(GS_SOEXT)
 #LDFLAGS_SO=-dynamiclib -flat_namespace
-#LDFLAGS_SO_MAC=-dynamiclib -install_name $(GS_SONAME_MAJOR_MINOR)
+LDFLAGS_SO_MAC=-dynamiclib -install_name __PREFIX__/lib/$(GS_SONAME_MAJOR_MINOR)
 #LDFLAGS_SO=-dynamiclib -install_name $(FRAMEWORK_NAME)
 
 GS_SO=$(BINDIR)/$(GS_SONAME)
