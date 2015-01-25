require "net/ftp"

module PACKMAN
  class Commands
    ListenPort = 30000
    ResponsePort = 30001
    RequestTotalTimeout = 10
    RequestRecvTimeout = 1

    def self.mirror
      PackageLoader.load_package :Proftpd
      if CommandLine.has_option? '-init'
        init_mirror_service
      elsif CommandLine.has_option? '-start'
        start_mirror_service
        start_mirror_discovery_service
      elsif CommandLine.has_option? '-stop'
        stop_mirror_service
        stop_mirror_discovery_service
      elsif CommandLine.has_option? '-status'
        status_mirror_service
      elsif CommandLine.has_option? '-sync'
        sync_mirror_service
      elsif CommandLine.has_option? '-scan'
        scan_mirror_server_discovery_service
      end
    end

    def self.get_ftp_port
      port = File.open("#{PACKMAN.prefix(Proftpd)}/../config/proftpd.conf", 'r').read.scan(/^Port\s+(\d+)/)[0][0]
    end

    def self.init_mirror_service
      # Install proftpd.
      proftpd = Proftpd.new
      proftpd.compiler_set_indices << 0
      install_package proftpd
      # Check available port for FTP service.
      port = 2121
      while port <= 10000
        if not PACKMAN::NetworkManager.is_port_open? 'localhost', port
          is_found_aval_port = true
          break
        end
        port += 1
      end
      if not is_found_aval_port
        PACKMAN.report_error 'Can not find an available port!'
      else
        PACKMAN.report_notice "Use port #{port} for FTP mirror service."
      end
      # Edit proftpd config file.
      PACKMAN.replace "#{PACKMAN.prefix(Proftpd)}/../config/proftpd.conf", {
        /^ServerName.*$/ => 'ServerName "PACKMAN FTP Mirror Service"',
        /^Port.*$/ => "Port #{port}",
        /^<Anonymous\s*.*>$/ => "<Anonymous #{ConfigManager.package_root}>"
      }
      # Check proftpd session.
      if status_mirror_service :silent
        CLI.report_notice 'FTP mirror service is already on.'
        return
      end
      sync_mirror_service
    end

    def self.start_mirror_service
      if status_mirror_service :silent
        CLI.report_notice 'FTP mirror service is already on.'
        return
      end
      CLI.report_notice "Start FTP mirror service."
      cmd = "#{PACKMAN.prefix(Proftpd)}/sbin/proftpd"
      if ENV['USER'] != 'root'
        system "sudo #{cmd}"
      else
        system cmd
      end
      CLI.report_notice "Broadcast #{CLI.green "ftp://#{PACKMAN.ip}:#{get_ftp_port}"}."
    end

    def self.stop_mirror_service
      if not status_mirror_service :silent
        CLI.report_notice 'FTP mirror service is already off.'
        return
      end
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
        proftpd = Net::FTP.new
        proftpd.connect 'localhost', get_ftp_port
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
      # Load all packages first.
      Package.all_package_names.each do |package_name|
        PackageLoader.load_package package_name
      end
      Commands.collect :all
      # Download Ruby.
      ruby_file_name = 'ruby-2.1.3.tar.bz2'
      ruby_url = "http://cache.ruby-lang.org/pub/ruby/2.1/#{ruby_file_name}"
      ruby_sha1 = 'befbc7b31b0e19c2abe8fa89f08de5d4d7509d19'
      ruby_file = "#{ConfigManager.package_root}/#{ruby_file_name}"
      if not File.exist? ruby_file or not PACKMAN.sha1_same? ruby_file, ruby_sha1
        CLI.report_notice "Download #{CLI.blue ruby_file}."
        PACKMAN.download ConfigManager.package_root, ruby_url, ruby_file_name
      end
      # Pack PACKMAN itself.
      CLI.report_notice "Packing #{CLI.green 'PACKMAN'} itself."
      PACKMAN.work_in "#{ENV['PACKMAN_ROOT']}/.." do
        system "tar czf packman.tar.gz --exclude='packman.config' #{File.basename ENV['PACKMAN_ROOT']}"
        PACKMAN.mv 'packman.tar.gz', ConfigManager.package_root
      end
    end

    def self.start_mirror_discovery_service
      pid_file = "#{ENV['PACKMAN_ROOT']}/.mirror_discovery_service_pid"
      if File.exist? pid_file
        CLI.report_warning "FTP mirror discovery service seems to be on."
        return
      end
      CLI.report_notice "Start FTP mirror discovery service."
      pid = fork do
        requests = {}
        BasicSocket.do_not_reverse_lookup = true
        listen_sock = UDPSocket.new
        listen_sock.bind '0.0.0.0', ListenPort
        response_sock = UDPSocket.new
        while true
          msg, addr = listen_sock.recvfrom 1024
          if requests[addr[2]] == msg
            next
          else
            requests[addr[2]] = msg
          end
          response_sock.send get_ftp_port, 0, addr[2], ResponsePort
        end
        listen_sock.close
        response_sock.close
      end
      Process.detach pid
      File.open(pid_file, 'w').write pid
    end

    def self.stop_mirror_discovery_service
      pid_file = "#{ENV['PACKMAN_ROOT']}/.mirror_discovery_service_pid"
      if not File.exist? pid_file
        CLI.report_warning "FTP mirror discovery service seems to be off."
        exit
      end
      pid = File.open(pid_file, 'r').read
      CLI.report_notice "Stop FTP mirror discovery service."
      system "kill -TERM #{pid}"
      PACKMAN.rm pid_file
    end

    def self.scan_mirror_server_discovery_service
      request_sock = UDPSocket.new
      request_sock.setsockopt Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
      listen_sock = UDPSocket.new
      listen_sock.bind '0.0.0.0', ResponsePort
      start_time = Time.now
      CLI.report_notice "Available FTP mirror server:"
      while (Time.now-start_time) < RequestTotalTimeout
        request_sock.send Process.pid.to_s, 0, '255.255.255.255', ListenPort
        begin
          Timeout::timeout RequestRecvTimeout do
            msg, addr = listen_sock.recvfrom 1024
            print "#{CLI.blue '==>'} ftp://#{addr[2]}:#{msg}\n"
          end
        rescue Timeout::Error
        end
      end
      request_sock.close
      listen_sock.close
    end
  end
end
