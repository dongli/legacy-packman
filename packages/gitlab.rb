require 'sequel'

class Gitlab < PACKMAN::Package
  url 'https://github.com/gitlabhq/gitlabhq/archive/v7.12.2.tar.gz'
  sha1 'af3b0d0f78ed812a456792ddedd80dc8c0aaa3a1'
  filename 'gitlab-7.12.2.tar.gz'
  version '7.12.2'

  label :compiler_insensitive
  label :installed_with_source
  label :not_use_target_dir_option

  option 'domain' => 'localhost'
  option 'port' => 8080
  option 'admin_email_address' => 'email.server.com'
  option 'admin_email_port' => 456
  option 'admin_email_user' => 'smtp'
  option 'admin_email_domain' => 'gitlab.company.com'
  option 'admin_email_password' => 'xxxxx' # TODO: How to set email password wisely?

  depends_on 'postgresql'
  depends_on 'redis'
  depends_on 'git'
  depends_on 'ruby'
  depends_on 'ruby_sequel'
  depends_on 'ruby_nokogiri'
  depends_on 'libiconv'
  depends_on 'icu4c'

  attach 'gitlab_shell' do
    url 'https://github.com/gitlabhq/gitlab-shell/archive/v2.6.3.tar.gz'
    sha1 '28320c744530a62362d922076f8008535d7cb7ac'
    filename 'gitlab-shell-2.6.3.tar.gz'
  end

  if PACKMAN.mac?
    @@user_home = '/Users/git'
  else
    @@user_name = '/home/git'
  end

  @@gitlab_home       = @@user_home+'/gitlab'
  @@repositories      = @@user_home+'/repositories'
  @@gitlab_satellites = @@user_home+'/gitlab-satellites'
  @@uploads           = @@gitlab_home+'/public/uploads'
  @@pids              = @@gitlab_home+'/tmp/pids'
  @@logs              = @@gitlab_home+'/log'
  @@sockets           = @@gitlab_home+'/tmp/sockets'
  @@redis_sock        = @@sockets+'/redis.sock'
  @@redis_dir         = @@gitlab_home+'/var/db/redis'
  @@redis_pid         = @@pids+'/redis.pid'
  @@redis_log         = @@logs+'/redis.log'

  def database_must_online! db = nil
    begin
      db ||= Sequel.postgres('postgres', :host => 'localhost')
      db.test_connection
    rescue
      PACKMAN.report_error "#{PACKMAN.blue 'Postgresql'} is #{PACKMAN.red 'off'}! Start it first."
    end
  end

  def install
    PACKMAN.os.create_user('git', [:with_home, :with_group, :hide_login]) unless PACKMAN.os.check_user 'git'
    if not File.directory? @@user_home
      PACKMAN.report_error "User home for #{PACKMAN.red 'git'} does not exist!"
    end
    db = Sequel.postgres('postgres', :host => 'localhost')
    database_must_online! db
    if not db[:pg_roles][:rolname => 'git']
      PACKMAN.run "createuser --pwprompt git"
      db.run "ALTER ROLE git WITH CREATEDB"
    end
    if not db[:pg_database][:datname => 'gitlabhq_production']
      PACKMAN.run "createdb --owner=git gitlabhq_production"
    end
    PACKMAN.work_in @@user_home do
      if not File.directory? 'gitlab-shell'
        PACKMAN.run "sudo -u git tar xf #{gitlab_shell.package_path}"
        PACKMAN.run "sudo -u git mv gitlab-shell-* gitlab-shell"
      end
      PACKMAN.work_in 'gitlab-shell' do
        PACKMAN.run "sudo -u git cp config.yml.example config.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/user: git/user: git/g\" config.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/home\\/git/#{@@user_home.gsub('/', '\\/')}/g\" config.yml" if PACKMAN.mac?
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/usr\\/bin\\/redis-cli/#{Redis.bin.gsub('/', '\\/')}\\/redis-cli/\" config.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/var\\/run\\/redis\\/redis.sock/#{@@redis_sock.gsub('/', '\\/')}/\" config.yml"
        PACKMAN.run "sudo -u git -H ./bin/install"
      end
      if not File.directory? 'gitlab'
        PACKMAN.run "sudo -u git tar xf #{package_path}"
        PACKMAN.run "sudo -u git mv gitlabhq-* gitlab"
      end
      # Configure GitLab.
      PACKMAN.work_in 'gitlab' do
        PACKMAN.run "sudo -u git cp config/gitlab.yml.example config/gitlab.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/home\\/git/#{@@user_home.gsub('/', '\\/')}/g\" config/gitlab.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/usr\\/bin\\/git/#{Git.bin.gsub('/', '\\/')}\\/git/\" config/gitlab.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/host: localhost/host: #{domain}/\" config/gitlab.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/port: 80/port: #{port}/\" config/gitlab.yml"
        PACKMAN.run "sudo -u git cp config/initializers/smtp_settings.rb.sample config/initializers/smtp_settings.rb"
        PACKMAN.run "sudo -u git sed -i '' \"s/address: .*/address: \\\"#{admin_email_address}\\\",/\" config/initializers/smtp_settings.rb"
        PACKMAN.run "sudo -u git sed -i '' \"s/port: .*/port: \\\"#{admin_email_port}\\\",/\" config/initializers/smtp_settings.rb"
        PACKMAN.run "sudo -u git sed -i '' \"s/user_name: .*/user_name: \\\"#{admin_email_user}\\\",/\" config/initializers/smtp_settings.rb"
        PACKMAN.run "sudo -u git sed -i '' \"s/password: .*/password: \\\"#{admin_email_password}\\\",/\" config/initializers/smtp_settings.rb"
        PACKMAN.run "sudo -u git sed -i '' \"s/domain: .*/domain: \\\"#{admin_email_domain}\\\",/\" config/initializers/smtp_settings.rb"
        PACKMAN.run "sudo chown -R git log/"
        PACKMAN.run "sudo chown -R git tmp/"
        PACKMAN.run "sudo chmod -R u+rwX log/"
        PACKMAN.run "sudo chmod -R u+rwX tmp/"
        # Create 'repositories' directory.
        if not File.exists? @@repositories
          PACKMAN.run "sudo -u git mkdir #{@@repositories}" 
          PACKMAN.run "sudo chown -R git:git #{@@repositories}"
          PACKMAN.run "sudo chmod -R ug+rwX,o-rwx #{@@repositories}"
          PACKMAN.run "sudo chmod -R ug-s #{@@repositories}"
          PACKMAN.run "sudo find #{@@repositories}-type d -print0 | sudo xargs -0 chmod g+s"
        end
        # Create 'gitlab-satellites' directory.
        if not File.exists? @@gitlab_satellites
          PACKMAN.run "sudo -u git mkdir #{@@gitlab_satellites}"
          PACKMAN.run "sudo chmod u+rwx,g=rx,o-rwx #{@@gitlab_satellites}"
        end
        # Create 'pids', 'sockets', 'uploads' directories.
        [@@pids, @@sockets, @@uploads].each do |dir|
          next if File.exists? dir
          PACKMAN.run "sudo -u git mkdir #{dir}"
          PACKMAN.run "sudo chmod -R u+rwX #{dir}"
        end
        # Modify 'unicorn.rb'.
        PACKMAN.run "sudo -u git cp config/unicorn.rb.example config/unicorn.rb"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/home\\/git/#{@@user_home.gsub('/', '\\/')}/g\" config/unicorn.rb"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\(listen .*\\.socket\\)/#\\1/\" config/unicorn.rb"
        #
        PACKMAN.run "sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb"
        # TODO: Fix this.
        PACKMAN.run "sudo mkdir /etc/logrotate.d" if not File.exist? '/etc/logrotate.d'
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/home\\/git/#{@@user_home.gsub('/', '\\/')}/g\" lib/support/logrotate/gitlab"
        PACKMAN.run "sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab"
        #
        PACKMAN.run "sudo -u git cp config/database.yml.postgresql config/database.yml"
        # Modify Gemfile and Gemfile.lock.
        PACKMAN.run "sudo -u git sed -i '' \"s/source \\\"https:\\/\\/rubygems.org\\\"/source \\\"#{PACKMAN.gem_source.gsub('/', '\\/')}\\\"/\" Gemfile"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\(gem \\\"underscore-rails\\\", \\\"~>\\).*/\\1 1.5.2\\\"/\" Gemfile"
        PACKMAN.run "sudo -u git sed -i '' \"s/charlock_holmes .*$/charlock_holmes (0.7.2)/\" Gemfile.lock"
        PACKMAN.run "sudo -u git sed -i '' \"s/underscore-rails (1\\.4\\.4)/underscore-rails (1.5.2)/g\" Gemfile.lock"
        PACKMAN.run "sudo -u git sed -i '' \"s/underscore-rails (~> 1\\.4\\.4)/underscore-rails (~> 1.5.2)/g\" Gemfile.lock"
        # TODO: Fix this.
        PACKMAN.run "gem install bundler"
        PACKMAN.run "sudo -u git -H bundle config build.charlock_holmes --with-icu-dir=#{Icu4c.prefix}"
        PACKMAN.run "sudo -u git -H bundle config build.nokogiri --with-iconv-dir=#{Libiconv.prefix}"
        PACKMAN.run "sudo -u git -H bundle install --path vendor/bundle --deployment --without development test mysql aws"
        PACKMAN.run_no_redirect "sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production"
        PACKMAN.run "sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production"
        # Modify 'redis.conf'.
        PACKMAN.run "sudo -u git -H cp #{Redis.etc+'/redis.conf'} ."
        PACKMAN.run "sudo -u git sed -i '' \"s/port 6379/port 0/\" redis.conf"
        PACKMAN.run "sudo -u git sed -i '' \"s/# unixsocket .*/unixsocket #{@@redis_sock.gsub('/', '\\/')}/\" redis.conf"
        PACKMAN.run "sudo -u git sed -i '' \"s/# unixsocketperm 700/unixsocketperm 777/\" redis.conf"
        PACKMAN.run "sudo -u git sed -i '' \"s/dir .*/dir #{@@redis_dir.gsub('/', '\\/')}/\" redis.conf"
        PACKMAN.run "sudo -u git sed -i '' \"s/pidfile .*/pidfile #{@@redis_pid.gsub('/', '\\/')}/\" redis.conf"
        PACKMAN.run "sudo -u git sed -i '' \"s/logfile .*/logfile #{@@redis_log.gsub('/', '\\/')}/\" redis.conf"
        PACKMAN.run "sudo -u git sed -i '' \"s/daemonize no/daemonize yes/\" redis.conf"
        PACKMAN.run "sudo -u git mkdir -p #{@@redis_dir}"
        PACKMAN.run "sudo -u git touch #{@@redis_pid}"
        PACKMAN.run "sudo -u git touch #{@@redis_log}"
        # Modify 'resque.yml'.
        PACKMAN.run "sudo -u git -H cp config/resque.yml.example config/resque.yml"
        PACKMAN.run "sudo -u git sed -i '' \"s/\\/var\\/run\\/redis\\/redis.sock/#{@@redis_sock.gsub('/', '\\/')}/\" config/resque.yml"
      end
      # Change all the files writable by the ENV['USER']!
      PACKMAN.os.add_user_to_group ENV['USER'], 'git'
      PACKMAN.run 'sudo chmod -R g+w *'
    end
  end

  def start
    database_must_online!
    PACKMAN.work_in @@gitlab_home do
      if File.exist? "#{@@pids}/redis.pid"
        if PACKMAN.is_process_running? `cat #{@@pids}/redis.pid`
          PACKMAN.report_error "#{PACKMAN.red 'Redis'} is already running!"
        end
      end
      PACKMAN.report_notice "Start #{PACKMAN.blue 'redis'} service."
      system "#{Redis.bin}/redis-server #{@@gitlab_home}/redis.conf"
      PACKMAN.report_error "Failed to start #{PACKMAN.blue 'redis'} service! See #{PACKMAN.red "#{@@logs}/redis.log"} for details." if not $?.success?
      if File.exist? "#{@@pids}/unicorn.pid"
        if PACKMAN.is_process_running? `cat #{@@pids}/unicorn.pid`
          PACKMAN.report_error "#{PACKMAN.red 'Unicorn'} is already running!"
        end
      end
      PACKMAN.report_notice "Start #{PACKMAN.blue 'unicorn'} service."
      system "bundle exec unicorn_rails -D -c #{@@gitlab_home}/config/unicorn.rb -E production 2>&1 1>/dev/null 2>&1"
      PACKMAN.report_error "Failed to start #{PACKMAN.blue 'unicorn'} service! See #{PACKMAN.red "#{@@logs}/unicorn.stderr.log"} for details." if not $?.success?
      if File.exist? "#{@@pids}/sidekiq.pid"
        if PACKMAN.is_process_running? `cat #{@@pids}/sidekiq.pid`
          PACKMAN.report_error "#{PACKMAN.red 'Sidekiq'} is already running!"
        end
      end
      PACKMAN.report_notice "Start #{PACKMAN.blue 'sidekiq'} service."
      system "bundle exec sidekiq -d -q post_receive -q mailer -q archive_repo -q system_hook -q project_web_hook -q gitlab_shell -q common -q default -e production -P #{@@pids}/sidekiq.pid -L #{@@logs}/sidekiq.log"
      PACKMAN.report_error "Failed to start #{PACKMAN.blue 'sidekiq'} service! See #{PACKMAN.red "#{@@logs}/sidekiq.log"} for details." if not $?.success?
    end
    return
    # TODO: Fix me.
    redis = Redis.new
    redis.stop(:label => 'org.packman.gitlab.redis') if redis.status(:label => 'org.packman.gitlab.redis')
    redis.start(
      :label => 'org.packman.gitlab.redis',
      :command => Redis.bin+'/redis-server',
      :arguments => @@gitlab_home+'/redis.conf',
      :working_directory => @@redis_dir,
      :run_at_load => true
    )
    PACKMAN.os.start_cron_job({
      :label => 'org.packman.gitlab.web',
      # :group_name => 'git',
      # :user_name => 'git',
      :command => 'bundle',
      :arguments => "exec unicorn_rails -D -c #{@@gitlab_home}/config/unicorn.rb -E production",
      :working_directory => @@gitlab_home,
      :run_at_load => true,
      :keep_alive => true
    })
    PACKMAN.os.start_cron_job({
      :label => 'org.packman.gitlab.background_jobs',
      # :group_name => 'git',
      # :user_name => 'git',
      :command => 'bundle',
      :arguments => %W[
        exec sidekiq
        -q post_receive
        -q mailer
        -q archive_repo
        -q system_hook
        -q project_web_hook
        -q gitlab_shell
        -q common
        -q default
        -e production
        -P #{@@pids}/sidekiq.pid
        -L #{@@logs}/sidekiq.log
      ],
      :working_directory => @@gitlab_home,
      :run_at_load => true,
      :keep_alive => true
    })
  end

  def status
    if File.exist? "#{@@pids}/redis.pid"
      redis_pid = `cat #{@@pids}/redis.pid`.chomp
    else
      return false
    end
    if File.exist? "#{@@pids}/unicorn.pid"
      unicorn_pid = `cat #{@@pids}/unicorn.pid`.chomp
    else
      return false
    end
    if File.exist? "#{@@pids}/sidekiq.pid"
      sidekiq_pid = `cat #{@@pids}/sidekiq.pid`.chomp
    else
      return false
    end
    PACKMAN.is_process_running?(redis_pid)   &&
    PACKMAN.is_process_running?(unicorn_pid) &&
    PACKMAN.is_process_running?(sidekiq_pid)
  end

  def stop
    if File.exist? "#{@@pids}/redis.pid"
      PACKMAN.report_notice "Stop #{PACKMAN.blue 'redis'} service."
      system "kill -TERM #{`cat #{@@pids}/redis.pid`.chomp} 2>&1 1>/dev/null 2>&1"
      system "rm -rf #{@@pids}/redis.pid"
    end
    if File.exist? "#{@@pids}/unicorn.pid"
      PACKMAN.report_notice "Stop #{PACKMAN.blue 'unicorn'} service."
      system "kill -TERM #{`cat #{@@pids}/unicorn.pid`.chomp} 2>&1 1>/dev/null 2>&1"
      system "rm -rf #{@@pids}/unicorn.pid"
    end
    if File.exist? "#{@@pids}/sidekiq.pid"
      PACKMAN.report_notice "Stop #{PACKMAN.blue 'sidekiq'} service."
      system "kill -TERM #{`cat #{@@pids}/sidekiq.pid`.chomp} 2>&1 1>/dev/null 2>&1"
      system "rm -rf #{@@pids}/sidekiq.pid"
    end
    return
    # TODO: Fix me.
    redis = Redis.new
    redis.stop(:label => 'org.packman.gitlab.redis') if redis.status(:label => 'org.packman.gitlab.redis')
    PACKMAN.os.stop_cron_job :label => 'org.packman.gitlab.web'
    PACKMAN.os.stop_cron_job :label => 'org.packman.gitlab.background_jobs'
  end
end