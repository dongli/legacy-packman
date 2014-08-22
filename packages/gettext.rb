class Gettext < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/gettext/gettext-0.19.2.tar.xz'
  sha1 '81b6ee521412b8042085342ab4df19f11b280e41'
  version '0.19.2'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
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
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end