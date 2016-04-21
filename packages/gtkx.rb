class Gtkx < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.25.tar.xz'
  sha1 '017ee13f172a64026c4e77c3744eeabd5e017694'
  version '2.24.25'

  depends_on :glib
  depends_on :libiconv
  depends_on :gettext
  depends_on :jpeg
  depends_on :libpng
  depends_on :libtiff
  depends_on :fontconfig
  depends_on :freetype
  depends_on :gdk_pixbuf
  depends_on :pango
  depends_on :jasper
  depends_on :atk
  depends_on :cairo
  depends_on :x11
  depends_on :gobject_introspection

  def install
    PACKMAN.handle_unlinked Freetype if PACKMAN.mac?
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-glibtest
      --enable-introspection=yes
      --disable-visibility
    ]
    PACKMAN.run './configure', *args
    PACKMAN.replace 'gdk/Makefile', /^(GDK_DEP_CFLAGS.*)$/ => "\\1 -I#{X11.inc}"
    PACKMAN.run 'make install'
  end
end
