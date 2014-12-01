require "socket"
require "timeout"
require "resolv"

module PACKMAN
  class NetworkManager
    def self.delegated_methods
      [:ip, :is_connect_internet?, :is_port_open?]
    end

    def self.ip
      Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
    end

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
end
