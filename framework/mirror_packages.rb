module PACKMAN
  def self.mirror_packages
    if CommandLine.has_option? '-init'
      init_mirror_service
    elsif CommandLine.has_option? '-start'
      start_mirror_service
    elsif CommandLine.has_option? '-stop'
      stop_mirror_service
    end
  end

  def self.init_mirror_service
    # Download all packages.
    report_notice 'Download all defined packages.'
    collect_packages :all => true
    # Install proftpd.
    Package.install [ConfigManager.compiler_sets[0]], Proftpd.new
    # Edit proftpd config file.
    replace "#{Package.prefix(Proftpd)}/../config/proftpd.conf", {
      /^ServerName.*$/ => 'ServerName "PACKMAN FTP Mirror Service"',
      /^<Anonymous\s*.*>$/ => "<Anonymous #{ConfigManager.package_root}>"
    }
  end

  def self.start_mirror_service
    Package.compiler_set = ConfigManager.compiler_sets[0]
    report_notice "Start FTP mirror service."
    if ENV['USER'] != 'root'
      system "sudo #{Package.prefix(Proftpd)}/sbin/proftpd"
    else
      system "#{Package.prefix(Proftpd)}/sbin/proftpd"
    end
  end

  def self.stop_mirror_service
    Package.compiler_set = ConfigManager.compiler_sets[0]
    pid = "#{Package.prefix(Proftpd)}/var/proftpd.pid"
    if not File.exist? pid
      report_warning "FTP mirror service is not running!"
      exit
    end
    report_notice "Stop FTP mirror service."
    if ENV['USER'] != 'root'
      system "sudo kill -TERM `cat #{pid}`"
    else
      system "kill -TERM `cat #{pid}`"
    end
  end
end
