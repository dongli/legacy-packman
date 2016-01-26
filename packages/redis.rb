class Redis < PACKMAN::Package
  url 'http://download.redis.io/releases/redis-3.0.7.tar.gz'
  sha1 '33d54a76e9b9260f40b14a5b0e9030b8d3b32c76'
  version '3.0.7'

  label :compiler_insensitive

  option :use_jemalloc => false
  option :config_file => :string # Default: .../etc/redis.conf

  def install
    args = %W[
      PREFIX=#{prefix}
      CC=#{PACKMAN.compiler(:c).command}
    ]
    args << 'MALLOC=jemalloc' if use_jemalloc?
    PACKMAN.run 'make install', *args
    %w[run db/redis log].each { |p| PACKMAN.mkdir var+'/'+p }
    PACKMAN.replace 'redis.conf', {
      '/var/run/redis.pid' => var+'/run/redis.pid',
      'dir ./' => 'dir '+var+'/db/redis/',
      '# bind 127.0.0.1' => 'bind 127.0.0.1',
      'daemonize no' => 'daemonize yes'
    }
    PACKMAN.mkdir etc
    PACKMAN.cp 'redis.conf', etc
    PACKMAN.cp 'sentinel.conf', etc+'/redis-sentinel.conf'
  end

  def start options = {}
    config_file = [config_file, options[:config_file], "#{etc}/redis.conf"].find { |x| x }
    PACKMAN.run "#{bin}/redis-server #{config_file}"
  end

  def status
    PACKMAN.run "#{bin}/redis-cli info", :skip_error
    $?.success? ? :on : :off
  end

  def stop
    return 'already off' if status == :off
    PACKMAN.run "#{bin}/redis-cli shutdown"
  end
end
