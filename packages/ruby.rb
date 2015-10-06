class Ruby < PACKMAN::Package
  url 'https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz'
  sha1 '0d9e158534cb31e72740138b8f697b57b448e5c3'
  version '2.2.3'

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
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --disable-silent-rules
      --with-out-ext=tk
      --without-gmp
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
