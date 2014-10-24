require "socket"
require "timeout"
require "resolv"

module PACKMAN
  class NetworkManager
    def self.is_connect_internet?
      if not defined? @@is_connect_internet
        dns_resolver = Resolv::DNS.new()
        begin
          dns_resolver.getaddress("symbolics.com")
          @@is_connect_internet = true
        rescue Resolv::ResolvError => e
          @@is_connect_internet = false
        end
      end
      return @@is_connect_internet
    end

    def self.is_port_open? ip, port
      begin
        Timeout::timeout(1) do
          begin
            s = TCPSocket.new ip, port
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
      end
      return false
    end
  end

  def self.is_port_open? ip, port
    NetworkManager.is_port_open? ip, port
  end
end