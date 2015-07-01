class Postgresql < PACKMAN::Package
  url 'https://ftp.postgresql.org/pub/source/v9.4.4/postgresql-9.4.4.tar.bz2'
  sha1 'e295fee0f1bace740b2db1eaa64ac060e277d5a7'
  version '9.4.4'

  label :compiler_insensitive

  option 'with_perl' => false
  option 'with_python' => false
  option 'create_postgres_user' => false

  depends_on 'openssl'
  depends_on 'readline'
  depends_on 'gettext'
  depends_on 'libxml2'
  depends_on 'zlib'
  depends_on 'uuid'
  depends_on 'perl' if with_perl?
  depends_on 'python' if with_python?

  def install
    PACKMAN.append_env 'LANG', 'C'
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --enable-nls
      --with-openssl
      --with-libxml
      --with-zlib
      --with-uuid=e2fs
    ]
    args << '--with-bonjour' if PACKMAN.mac?
    PACKMAN.set_cppflags_and_ldflags [Openssl, Readline, Gettext, Zlib, Uuid]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install-world'
  end

  def post_install
    if create_postgres_user? and not PACKMAN.os.check_user 'postgres'
      PACKMAN.os.create_user 'postgres'
    end
  end
end
