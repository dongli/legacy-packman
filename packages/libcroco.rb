class Libcroco < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/GNOME/sources/libcroco/0.6/libcroco-0.6.5.tar.xz'
  sha1 '0ea3a5b7c545e4ff527ce02198020866303ab351'
  version '0.6.5'

  depends_on 'glib'
  depends_on 'intltool'
  depends_on 'libxml2'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-Bsymbolic
    ]
    PACKMAN.set_cppflags_and_ldflags [Glib, Libxml2]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
