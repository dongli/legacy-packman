class Librsvg < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/GNOME/sources/librsvg/2.36/librsvg-2.36.3.tar.xz'
  sha1 '8ac22591c9db273355cf895f7e87aac149f64437'
  version '2.36.3'

  depends_on 'pkgconfig'
  depends_on 'x11'
  depends_on 'gtkx'
  depends_on 'libcroco'
  depends_on 'libgsf'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-Bsymbolic
      --enable-tools=yes
      --enable-pixbuf-loader=yes
      --enable-introspection=no
      --enable-svgz
    ]
    PACKMAN::AutotoolHelper.set_cppflags_and_ldflags args, [Gtkx, Libcroco, Libgsf]
    PACKMAN.run './configure', *args
    args = %W[
      gdk_pixbuf_binarydir=#{Gdk_pixbuf.lib}/gdk-pixbuf-2.0/2.10.0/loaders
      gdk_pixbuf_moduledir=#{Gdk_pixbuf.lib}/gdk-pixbuf-2.0/2.10.0/loaders
    ]
    PACKMAN.run 'make install', *args
  end

  def postfix
    PACKMAN.run "export GDK_PIXBUF_MODULEDIR=#{Gdk_pixbuf.lib}/gdk-pixbuf-2.0/2.10.0/loaders && gdk-pixbuf-query-loaders --update-cache"
  end
end
