class Redis < PACKMAN::Package
  url 'http://download.redis.io/releases/redis-3.0.3.tar.gz'
  sha1 '0e2d7707327986ae652df717059354b358b83358'
  version '3.0.3'

  label :compiler_insensitive

  option 'use_jemalloc' => false
  option 'config_file' => :string

  def install
    args = %W[
      PREFIX=#{prefix}
      CC=#{PACKMAN.compiler('c').command}
    ]
    args << 'MALLOC=jemalloc' if use_jemalloc?
    PACKMAN.run 'make install', *args
    %w[run db/redis log].each { |p| PACKMAN.mkdir var+'/'+p }
    PACKMAN.replace 'redis.conf', {
      '/var/run/redis.pid' => var+'/run/redis.pid',
      'dir ./' => 'dir '+var+'/db/redis/',
      '# bind 127.0.0.1' => 'bind 127.0.0.1'
    }
    PACKMAN.mkdir etc
    PACKMAN.cp 'redis.conf', etc
    PACKMAN.cp 'sentinel.conf', etc+'/redis-sentinel.conf'
  end

  def start options = {}
    if options.empty?
      PACKMAN.os.start_cron_job(
        :label => 'org.packman.redis',
        :command => bin+'/redis-server',
        :arguments => config_file ? config_file : etc+'/redis.conf',
        :working_directory => var,
        :run_at_load => true,
        :stdout => var+'/log/redis.log',
        :stderr => var+'/log/redis.log'
      )
    else
      PACKMAN.os.start_cron_job options
    end
  end

  def status options = {}
    if options.empty?
      PACKMAN.os.status_cron_job :label => 'org.packman.redis'
    else
      PACKMAN.os.status_cron_job options
    end
  end

  def stop options = {}
    if options.empty?
      PACKMAN.os.stop_cron_job :label => 'org.packman.redis'
    else
      PACKMAN.os.stop_cron_job options
    end
  end
end
