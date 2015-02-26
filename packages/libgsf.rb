class Libgsf < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/GNOME/sources/libgsf/1.14/libgsf-1.14.30.tar.xz'
  sha1 '5eb15d574c6b9e9c5e63bbcdff8f866b3544485a'
  version '1.14.30'

  depends_on 'perl_xml_parser'
  depends_on 'intltool'
  depends_on 'gettext'
  depends_on 'glib'
  depends_on 'gdk_pixbuf'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.set_cppflags_and_ldflags [Gettext, Glib, Gdk_pixbuf]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
