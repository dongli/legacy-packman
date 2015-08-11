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
    PACKMAN.set_cppflags_and_ldflags [Openssl, Readline_, Gettext, Zlib, Uuid]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install-world'
  end

  def post_install
    PACKMAN.report_notice "Create system user #{PACKMAN.blue admin_user}."
    PACKMAN.os.create_user(admin_user, [:hide_login]) unless PACKMAN.os.check_user admin_user
    PACKMAN.report_notice "Initialize database cluster in #{cluster_path}."
    PACKMAN.run "sudo mkdir #{var}" if not Dir.exist? var
    PACKMAN.os.change_owner var, admin_user
    PACKMAN.run "sudo -u #{admin_user} #{bin}/initdb --pwprompt -U #{admin_user} -D #{cluster_path} -E UTF8"
  end

  def start
    cmd = "#{bin}/pg_ctl start -D #{cluster_path} -l #{var}/postgres.log"
    if ENV['USER'] != admin_user
      PACKMAN.run "sudo -u #{admin_user} #{cmd}"
    else
      PACKMAN.run cmd
    end
  end

  def stop
    cmd = "#{bin}/pg_ctl stop -D #{cluster_path}"
    if ENV['USER'] != admin_user
      PACKMAN.run "sudo -u #{admin_user} #{cmd}"
    else
      PACKMAN.run cmd
    end
  end

  def status
    cmd = "#{bin}/pg_ctl status -D #{cluster_path}"
    if ENV['USER'] != admin_user
      PACKMAN.run "sudo -u #{admin_user} #{cmd}"
    else
      PACKMAN.run cmd
    end
    $?.success? ? :on : :off
  end
end
