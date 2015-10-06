class Gettext < PACKMAN::Package
  url 'ftp://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.3.tar.gz'
  sha1 '8a4614d5d797af98822b88858c17ad8b3ed4224f'
  version '0.19.3'

  depends_on :libiconv

  def install
    if PACKMAN.mac? and PACKMAN.compiler(:c).vendor == :gnu
      # See https://github.com/andrewgho/movewin-ruby/issues/1.
      PACKMAN.report_error "#{PACKMAN.red 'Gettext'} cannot be built by GCC on Mac OS X!"
    end
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-debug
      --with-included-gettext
      --with-included-glib
      --with-included-libcroco
      --with-included-libunistring
      --with-emacs
      --disable-java
      --disable-csharp
      --without-git
      --without-cvs
      --without-xz
      --with-libiconv-prefix=#{Libiconv.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
