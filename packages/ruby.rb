class Ruby < PACKMAN::Package
  url 'https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz'
  sha1 '2dfcf7f33bda4078efca30ae28cb89cd0e36ddc4'
  version '2.3.0'

  label :compiler_insensitive

  depends_on :pkgconfig
  depends_on :ncurses
  depends_on :readline
  depends_on :gdbm
  depends_on :gmp
  depends_on :libffi
  depends_on :libyaml
  depends_on :openssl
  depends_on :zlib

  def install
    PACKMAN.handle_unlinked Openssl
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --disable-silent-rules
      --with-out-ext=tk
      LIBS='-L#{link_root}/lib -L#{Openssl.lib}'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
