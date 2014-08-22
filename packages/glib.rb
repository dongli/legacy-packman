class Glib < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/gnome/sources/glib/2.40/glib-2.40.0.tar.xz'
  sha1 '44e1442ed4d1bf3fa89138965deb35afc1335a65'
  version '2.40.0'

  depends_on 'gettext'
  depends_on 'libffi'

  def install
    # Disable dtrace; see https://trac.macports.org/ticket/30413
    args = %W[
      --disable-maintainer-mode
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    # PACKMAN.run 'ulimit -n 1024; make check'
    PACKMAN.run 'make install'
  end
end