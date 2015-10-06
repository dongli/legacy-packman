class Atk < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/gnome/sources/atk/2.14/atk-2.14.0.tar.xz'
  sha1 'b803d055c8e2f786782803b7d21e413718321db7'
  version '2.14.0'

  depends_on :glib
  depends_on :gobject_introspection

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-introspection=yes
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end

  def post_install
    # Copy DIR file into Gobject_introspection.
    PACKMAN.cp "#{share}/gir-1.0/*.gir", "#{Gobject_introspection.share}/gir-1.0"
  end
end