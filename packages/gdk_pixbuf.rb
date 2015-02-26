class Gdk_pixbuf < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/2.30/gdk-pixbuf-2.30.8.tar.xz'
  sha1 '6277b4e5b5e334b3669f15ae0376e184be9e8cd8'
  version '2.30.8'

  depends_on 'glib'
  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'libtiff'
  depends_on 'jasper'
  depends_on 'gobject_introspection'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-maintainer-mode
      --enable-debug=no
      --enable-introspection=yes
      --disable-Bsymbolic
      --without-gdiplus
      --with-jasper
    ]
    PACKMAN.set_cppflags_and_ldflags
      [Glib, Jpeg, Libpng, Libtiff, Jasper, Gobject_introspection]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end

  def postfix
    # Copy DIR file into Gobject_introspection.
    PACKMAN.cp "#{share}/gir-1.0/*.gir", "#{Gobject_introspection.share}/gir-1.0"
  end
end