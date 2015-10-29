class Glib < PACKMAN::Package
  url 'http://ftp.gnome.org/pub/gnome/sources/glib/2.46/glib-2.46.1.tar.xz'
  sha1 '903cc9442114f52a44096cb26a9479c85160c305'
  version '2.46.1'

  depends_on :pkgconfig
  depends_on :gettext
  depends_on :zlib
  depends_on :libffi
  depends_on :libiconv

  patch do
    url 'https://raw.githubusercontent.com/Homebrew/patches/59e4d32/glib/hardcoded-paths.diff'
    sha1 '78bbc0c7349d7bfd6ab1bfeabfff27a5dfb1825a'
  end

  patch do
    url 'https://raw.githubusercontent.com/Homebrew/patches/59e4d32/glib/gio.patch'
    sha1 '6f4ff17da9604e3959bb281e04801e3da3558034'
  end

  def install
    if PACKMAN.mac?
      if PACKMAN.compiler(:c).vendor == :gnu
        PACKMAN.report_error "#{PACKMAN.blue 'glib'} cannot be built by GCC on Mac OS X!"
      end
      PACKMAN.handle_unlinked Libiconv
    end
    # Disable dtrace; see https://trac.macports.org/ticket/30413
    args = %W[
      --prefix=#{prefix}
      --disable-maintainer-mode
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-dtrace
      --disable-libelf
      --with-libiconv=gnu
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    # PACKMAN.run 'ulimit -n 1024; make check'
    PACKMAN.run 'make install'

    PACKMAN.replace "#{lib}/pkgconfig/glib-2.0.pc", {
      /(Libs: -L\$\{libdir\} -lglib-2.0) (-lintl)/ => "\\1 -L#{Gettext.lib} \\2",
      /(Cflags: -I\$\{includedir\}\/glib-2.0 -I\$\{libdir\}\/glib-2.0\/include)/ => "\\1 -I#{Gettext.include}"
    }
  end
end
