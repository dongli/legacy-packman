class Logrotate < PACKMAN::Package
  url 'https://fedorahosted.org/releases/l/o/logrotate/logrotate-3.9.1.tar.gz'
  sha1 '7ba734cd1ffa7198b66edc4bca17a28ea8999386'
  version '3.9.1'

  label :compiler_insensitive

  depends_on 'popt'

  patch :embed

  def install
    PACKMAN.reset_env 'COMPRESS_COMMAND', '/usr/bin/gzip'
    PACKMAN.reset_env 'COMPRESS_EXT', '.gz'
    PACKMAN.reset_env 'UNCOMPRESS_COMMAND', '/usr/bin/gunzip'
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.set_cppflags_and_ldflags [Popt]
    PACKMAN.run './autogen.sh'
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
    PACKMAN.mkdir etc
    PACKMAN.mkdir etc+'/logrotate.d'
    PACKMAN.mkdir var+'/lib'
    PACKMAN.mv 'examples/logrotate-default', etc+'/logrotate.conf'
    PACKMAN.replace etc+'/logrotate.conf', {
      '/etc/logrotate.d' => etc+'/logrotate.d'
    }
  end

  def start
    PACKMAN.os.start_cron_job({
      :label => 'org.packman.logrotate',
      :command => sbin+'/logrotate',
      :arguments => [
        '-s '+var+'/lib/logrotate.status',
        etc+'/logrotate.conf'
      ],
      :every => { :hour => 6, :minute => 25 }
    })
  end

  def status
    PACKMAN.os.status_cron_job 'org.packman.logrotate'
  end

  def stop
    PACKMAN.os.stop_cron_job 'org.packman.logrotate'
  end
end

__END__
diff --git i/examples/logrotate-default w/examples/logrotate-default
index 56e9103..c61a33a 100644
--- i/examples/logrotate-default
+++ w/examples/logrotate-default
@@ -14,22 +14,7 @@ dateext
 # uncomment this if you want your log files compressed
 #compress
 
-# RPM packages drop log rotation information into this directory
+# PACKMAN packages drop log rotation information into this directory
 include /etc/logrotate.d
 
-# no packages own wtmp and btmp -- we'll rotate them here
-/var/log/wtmp {
-    monthly
-    create 0664 root utmp
-    minsize 1M
-    rotate 1
-}
-
-/var/log/btmp {
-    missingok
-    monthly
-    create 0600 root utmp
-    rotate 1
-}
-
 # system-specific logs may be also be configured here.
