class Ruby < PACKMAN::Package
  url 'http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.1.tar.gz'
  sha1 '12376b79163e02bc9bd1a39329d67c3d19ccace9'
  version '2.2.1'

  label :compiler_insensitive

  depends_on 'pkgconfig'
  depends_on 'readline'
  depends_on 'gdbm'
  depends_on 'gmp'
  depends_on 'libffi'
  depends_on 'libyaml'
  depends_on 'openssl'

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --disable-silent-rules
      --with-out-ext=tk
      --without-gmp
    ]
    PACKMAN.set_cppflags_and_ldflags [Readline, Gdbm, Gmp, Libffi, Libyaml, Openssl]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end