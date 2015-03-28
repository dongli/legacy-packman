class Pkgconfig < PACKMAN::Package
  url 'http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz'
  sha1 '71853779b12f958777bffcb8ca6d849b4d3bed46'
  version '0.28'

  label 'compiler_insensitive'

  def install
    if PACKMAN.mac? and PACKMAN.compiler_vendor('c') == 'gnu'
      # See https://github.com/andrewgho/movewin-ruby/issues/1.
      PACKMAN.report_error "#{PACKMAN.red 'Pkgconfig'} cannot be built by GCC on Mac OS X!"
    end
    pc_path = %W[
      /usr/local/lib/pkgconfig
      /usr/lib/pkgconfig
    ]
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-host-tool
      --with-internal-glib
      --with-pc-path=#{pc_path.join(':')}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end