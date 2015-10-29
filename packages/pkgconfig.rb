class Pkgconfig < PACKMAN::Package
  url 'http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.tar.gz'
  sha1 'f4b19d203b3896a4293af4b62c7f908063c88a5a'
  version '0.29'

  label :compiler_insensitive

  depends_on :libiconv

  def install
    if PACKMAN.mac?
      if PACKMAN.compiler(:c).vendor == :gnu
        PACKMAN.report_error "#{PACKMAN.blue 'pkgconfig'} cannot be built by GCC on Mac OS X!"
      elsif PACKMAN.compiler(:c).vendor == :llvm
        PACKMAN.append_env 'LDFLAGS', '-framework CoreFoundation -framework Carbon'
      end
    end
    PACKMAN.handle_unlinked Libiconv if PACKMAN.mac?
    pc_path = %W[
      /usr/local/lib/pkgconfig
      /usr/lib/pkgconfig
    ]
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-host-tool
      --with-libiconv=gnu
      --with-internal-glib
      --with-pc-path=#{pc_path.join(':')}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
