class Passenger < PACKMAN::Package
  url 'https://s3.amazonaws.com/phusion-passenger/releases/passenger-5.0.15.tar.gz'
  sha1 'b589f2f0bf54eb91299ad0b5be00de36ea9dbbfd'
  version '5.0.15'

  label :compiler_insensitive

  option 'with_apache2' => false
  option 'web_server' => 'nginx'
  option 'port' => 80
  option 'server_name' => PACKMAN.ip
  option 'app_root' => :string

  depends_on 'pcre'
  depends_on 'openssl'
  depends_on 'ruby'

  def install
    PACKMAN.run 'rake apache2' if with_apache2?
    PACKMAN.run 'rake nginx'
    # PACKMAN.run 'rake webhelper'
    PACKMAN.mkdir libexec+'/download_cache'
    # PACKMAN.rm 'buildout/libev'
    # PACKMAN.rm 'buildout/libeio'
    # PACKMAN.rm 'buildout/cache'
    %w[.editorconfig configure Rakefile README.md CONTRIBUTORS
      CONTRIBUTING.md LICENSE CHANGELOG INSTALL.md
      passenger.gemspec build lib node_lib bin doc man
      dev helper-scripts ext resources buildout].each do |f|
      PACKMAN.cp f, libexec
    end
    PACKMAN.mkdir bin
    PACKMAN.ln libexec+'/bin/*', bin
    locations_ini = `./bin/passenger-config --make-locations-ini --for-native-packaging-method=packman`
    locations_ini.gsub!(/=#{Regexp.escape Dir.pwd}/, "=#{libexec}")
    PACKMAN.write_file libexec+'/lib/phusion_passenger/locations.ini', locations_ini
    PACKMAN.run './dev/install_scripts_bootstrap_code.rb',
      '--ruby', libexec+'/lib', *Dir[libexec+'/bin/*']
    PACKMAN.run './dev/install_scripts_bootstrap_code.rb',
      '--nginx-module-config', libexec+'/bin', libexec+'/ext/nginx/config'
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
