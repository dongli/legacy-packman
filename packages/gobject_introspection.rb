class Gobject_introspection < PACKMAN::Package
  url "http://ftp.gnome.org/pub/GNOME/sources/gobject-introspection/1.42/gobject-introspection-1.42.0.tar.xz"
  sha1 'b3e095004aa8321a5a814aacd019e6953d69c4eb'
  version '1.42.0'

  depends_on 'flex'
  depends_on 'bison'
  depends_on 'python2'
  depends_on 'glib'
  depends_on 'libffi'
  depends_on 'cairo'

  if PACKMAN.mac?
    patch do
      url 'https://gist.githubusercontent.com/krrk/6958869/raw/de8d83009d58eefa680a590f5839e61a6e76ff76/gobject-introspection-tests.patch'
      sha1 '1f57849db76cd2ca26ddb35dc36c373606414dfc'
    end
  end

  def install
    PACKMAN.append_env 'GI_SCANNER_DISABLE_CACHE', 'true'
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-cairo
    ]
    PACKMAN.set_cppflags_and_ldflags [Glib, Libffi, Cairo]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    # PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
