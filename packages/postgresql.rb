class Postgresql < PACKMAN::Package
  url 'https://ftp.postgresql.org/pub/source/v9.4.4/postgresql-9.4.4.tar.bz2'
  sha1 'e295fee0f1bace740b2db1eaa64ac060e277d5a7'
  version '9.4.4'

  label :compiler_insensitive

  option 'with_perl' => false
  option 'with_python' => false
  option 'admin_user' => 'postgres'
  option 'cluster_path' => var+'/data'

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
    PACKMAN.mkdir var, :skip_if_exist
    PACKMAN.report_notice "Initialize database cluster in #{cluster_path}."
    PACKMAN.run "#{bin}/initdb --pwprompt -D #{cluster_path} -E UTF8"
    PACKMAN.os.create_user admin_user unless PACKMAN.os.check_user admin_user
    if ENV['USER'] != admin_user
      PACKMAN.os.change_owner var, admin_user
    end
  end

  def start
    PACKMAN.report_notice "Enter password of #{PACKMAN.blue admin_user}:"
    system "su #{admin_user} -c '#{bin}/pg_ctl start -D #{cluster_path} -l #{var}/postgres.log'"
  end

  def stop
    PACKMAN.report_notice "Enter password of #{PACKMAN.blue admin_user}:"
    system "su #{admin_user} -c '#{bin}/pg_ctl stop -D #{cluster_path}'"
  end

  def status
    PACKMAN.report_notice "Enter password of #{PACKMAN.blue admin_user}:"
    system "su #{admin_user} -c '#{bin}/pg_ctl status -D #{cluster_path}'"
    $?.success? ? :on : :off
  end
end
