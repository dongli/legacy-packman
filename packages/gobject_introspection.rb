class Gobject_introspection < PACKMAN::Package
  url "http://ftp.gnome.org/pub/GNOME/sources/gobject-introspection/1.42/gobject-introspection-1.42.0.tar.xz"
  sha1 'b3e095004aa8321a5a814aacd019e6953d69c4eb'
  version '1.42.0'

  depends_on 'glib'
  depends_on 'libffi'
  depends_on 'cairo'

  if PACKMAN::OS.mac_gang?
    patch do
      url 'https://gist.githubusercontent.com/krrk/6958869/raw/de8d83009d58eefa680a590f5839e61a6e76ff76/gobject-introspection-tests.patch'
      sha1 '1f57849db76cd2ca26ddb35dc36c373606414dfc'
    end
  end

  def install
    PACKMAN.append_env 'GI_SCANNER_DISABLE_CACHE=true'
    cppflags = []
    ldflags = []
    [Glib, Libffi, Cairo].each do |lib|
      cppflags << "-I#{PACKMAN.prefix lib}/include"
      ldflags << "-L#{PACKMAN.prefix lib}/lib"
    end
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
      --with-cairo
    ]
    args << "CPPFLAGS='#{cppflags.join(' ')}'"
    args << "LDFLAGS='#{ldflags.join(' ')}'"
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    # PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end