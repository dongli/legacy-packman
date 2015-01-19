class Gettext < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gettext/gettext-0.19.3.tar.xz'
  sha1 '5c8e37c5275742b6acc1257e2df9b5d1874c12e3'
  version '0.19.3'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
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
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end