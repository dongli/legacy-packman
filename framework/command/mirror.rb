require "net/ftp"

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
      proftpd = Proftpd.new
      proftpd.compiler_set_indices << 0
      install_package proftpd
      # Edit proftpd config file.
      PACKMAN.replace "#{PACKMAN.prefix(Proftpd)}/../config/proftpd.conf", {
        /^ServerName.*$/ => 'ServerName "PACKMAN FTP Mirror Service"',
        /^<Anonymous\s*.*>$/ => "<Anonymous #{ConfigManager.package_root}>"
      }
    end

    def self.start_mirror_service
      if status_mirror_service :silent
        CLI.report_notice 'FTP mirror service is already on.'
        return
      end
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
      if not status_mirror_service :silent
        CLI.report_notice 'FTP mirror service is already off.'
        return
      end
      Package.compiler_set = ConfigManager.compiler_sets[0]
      pid_file = "#{PACKMAN.prefix(Proftpd)}/var/proftpd.pid"
      if not File.exist? pid_file
        pid = `pgrep proftpd`.split("\n")
        if pid.size == 1
          pid = pid.first
          CLI.report_warning "#{CLI.red pid_file} does not exist, but there is another "+
            "#{CLI.red 'proftpd'} process (#{CLI.red pid})."
          CLI.ask 'Do you want to stop it?', ['yes', 'no']
          ans = CLI.get_answer ['yes', 'no']
          return if ans != [0]
        else
          CLI.report_error "There are multiple #{CLI.red 'proftpd'} processes!"
        end
      else
        pid = `cat #{pid_file}`
      end
      CLI.report_notice "Stop FTP mirror service."
      cmd = "kill -TERM #{pid}"
      if ENV['USER'] != 'root'
        system "sudo #{cmd}"
      else
        system cmd
      end
    end

    def self.status_mirror_service options = []
      options = [options] if not options.class == Array
      begin
        proftpd = Net::FTP.new 'localhost'
      rescue Errno::ECONNREFUSED
        CLI.report_notice "FTP mirror service is #{CLI.red 'off'}." if not options.include? :silent
        return false
      end
      begin
        proftpd.login
      rescue Net::FTPPermError
        CLI.report_error "There is another FTP server on this computer and it does not belong to PACKMAN!"
      end
      begin
        if proftpd.status =~ /PACKMAN FTP Mirror Service/
          CLI.report_notice "FTP mirror service is #{CLI.green 'on'}." if not options.include? :silent
          return true
        else
          CLI.report_error "There is another FTP server on this computer and it does not belong to PACKMAN!"
        end
      rescue
        CLI.report_error "There is another FTP server on this computer and it does not belong to PACKMAN!"
      end
    end

    def self.sync_mirror_service
      # Download all packages.
      CLI.report_notice 'Download all defined packages.'
      Commands.collect :all
    end
  end
end
