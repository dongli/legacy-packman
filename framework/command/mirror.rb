module PACKMAN
  class Commands
    def self.mirror
      PackageLoader.load_package :Proftpd
      if CommandLine.has_option? '-init'
        init_mirror_service
      elsif CommandLine.has_option? '-start'
        start_mirror_service
      elsif CommandLine.has_option? '-stop'
        stop_mirror_service
      elsif CommandLine.has_option? '-status'
        status_mirror_service
      elsif CommandLine.has_option? '-sync'
        sync_mirror_service
      else
        CLI.report_error "An option must be given!"
      end
    end

    def self.init_mirror_service
      sync_mirror_service
      # Install proftpd.
      install_package ConfigManager.compiler_sets[0], Proftpd.new
      # Edit proftpd config file.
      PACKMAN.replace "#{PACKMAN.prefix(Proftpd)}/../config/proftpd.conf", {
        /^ServerName.*$/ => 'ServerName "PACKMAN FTP Mirror Service"',
        /^<Anonymous\s*.*>$/ => "<Anonymous #{ConfigManager.package_root}>"
      }
    end

    def self.start_mirror_service
      Package.compiler_set = ConfigManager.compiler_sets[0]
      CLI.report_notice "Start FTP mirror service."
      cmd = "#{PACKMAN.prefix(Proftpd)}/sbin/proftpd"
      if ENV['USER'] != 'root'
        system "sudo #{cmd}"
      else
        system cmd
      end
    end

    def self.stop_mirror_service
      Package.compiler_set = ConfigManager.compiler_sets[0]
      pid = "#{PACKMAN.prefix(Proftpd)}/var/proftpd.pid"
      if not File.exist? pid
        CLI.report_warning "FTP mirror service is not running!"
        exit
      end
      CLI.report_notice "Stop FTP mirror service."
      cmd = "kill -TERM `cat #{pid}`"
      if ENV['USER'] != 'root'
        system "sudo #{cmd}"
      else
        system cmd
      end
    end

    def self.status_mirror_service
      Package.compiler_set = ConfigManager.compiler_sets[0]
      pid = "#{PACKMAN.prefix(Proftpd)}/var/proftpd.pid"
      if File.exist? pid
        CLI.report_notice "FTP mirror service is #{CLI.green 'on'}."
      else
        CLI.report_notice "FTP mirror service is #{CLI.red 'off'}."
      end
    end

    def self.sync_mirror_service
      # Download all packages.
      CLI.report_notice 'Download all defined packages.'
      Commands.collect :all
    end
  end
end
