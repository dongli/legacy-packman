class Pango < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/GNOME/sources/pango/1.36/pango-1.36.8.tar.xz'
  sha1 'c6ba02ee8f9d8b22b7cfd74c4b6ae170bebc8d2b'
  version '1.36.8'

  depends_on 'glib'
  depends_on 'cairo'
  depends_on 'harfbuzz'
  depends_on 'fontconfig'
  depends_on 'x11'
  depends_on 'gobject_introspection'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-man
      --enable-introspection=yes
      --with-xft
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end

  def postfix
    # Copy DIR file into Gobject_introspection.
    PACKMAN.cp "#{share}/gir-1.0/*.gir", "#{Gobject_introspection.share}/gir-1.0"
  end
end
