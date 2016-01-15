class Passenger < PACKMAN::Package
  url 'https://s3.amazonaws.com/phusion-passenger/releases/passenger-5.0.22.tar.gz'
  sha1 '8cc6ca03a6d4aac606c216fabbd4841fd944eff0'
  version '5.0.22'

  label :compiler_insensitive

  option :with_apache2 => false
  option :web_server => 'nginx'
  option :port => 80
  option :server_name => PACKMAN.ip
  option :app_root => :string

  depends_on :curl
  depends_on :zlib
  depends_on :pcre
  depends_on :openssl
  depends_on :ruby

  def install
    PACKMAN.replace 'build/basics.rb', {
      'AGENT_LDFLAGS = ""' => "AGENT_LDFLAGS = '#{PACKMAN.ldflags} #{PACKMAN.os.generate_rpaths(PACKMAN.link_root, :wrap_flag).join(' ')}'"
    }
    PACKMAN.replace 'src/ruby_supportlib/phusion_passenger/platform_info/zlib.rb', {
      'return nil' => "return '-I#{Zlib_.inc}'",
      "return '-lz'" => "return '-L#{Zlib_.lib} -lz'"
    }
    PACKMAN.run 'rake apache2' if with_apache2?
    PACKMAN.run 'rake nginx'
    PACKMAN.mkdir libexec+'/download_cache', :force
    PACKMAN.rm 'buildout/libev'
    PACKMAN.rm 'buildout/libeio'
    PACKMAN.rm 'buildout/cache'
    %w[.editorconfig configure Rakefile README.md CONTRIBUTORS
      CONTRIBUTING.md LICENSE CHANGELOG INSTALL.md
      passenger.gemspec build bin doc man src
      dev resources buildout].each do |f|
      PACKMAN.cp f, libexec
    end
    PACKMAN.mkdir bin
    PACKMAN.ln libexec+'/bin/*', bin
    locations_ini = `./bin/passenger-config --make-locations-ini --for-native-packaging-method=packman`
    locations_ini.gsub!(/=#{Regexp.escape Dir.pwd}/, "=#{libexec}")
    PACKMAN.write_file libexec+'/lib/phusion_passenger/locations.ini', locations_ini

    ruby_libdir = `./bin/passenger-config about ruby-libdir`.strip
    ruby_libdir.gsub!(/^#{Regexp.escape Dir.pwd}/, libexec)
    PACKMAN.run './dev/install_scripts_bootstrap_code.rb',
      '--ruby', ruby_libdir, *Dir[libexec+'/bin/*']

    nginx_addon_dir = `./bin/passenger-config about nginx-addon-dir`.strip
    nginx_addon_dir.gsub!(/^#{Regexp.escape Dir.pwd}/, libexec)
    PACKMAN.run './dev/install_scripts_bootstrap_code.rb',
      '--nginx-module-config', libexec+'/bin', nginx_addon_dir+'/config'
    PACKMAN.mkdir share
    PACKMAN.mv libexec+'/man', share
  end

  def deploy
    PACKMAN.report_error "#{PACKMAN.red 'app_root'} should be set!" if not app_root
    case web_server
    when 'nginx'
      PACKMAN.load_package 'nginx'
      PACKMAN.append Nginx.conf, <<-EOT.keep_indent

        server {
          listen #{port};
          server_name #{server_name};
          root #{app_root}/public;
          passenger_enabled on;
        }
      EOT
    else
      PACKMAN.report_error "Unsupported web server #{PACKMAN.red web_server}!"
    end
  end
end
