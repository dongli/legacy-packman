module PACKMAN
  class OS
    def self.type
      @@type
    end

    def self.distro
      @@distro
    end

    def self.version
      @@version
    end

    def self.scan
      res = `uname`
      case res
      when /^Darwin */
        @@type = :Darwin
      when /^Linux */
        @@type = :Linux
      else
        report_error "Unknown OS type \"#{res}\"!"
      end
      # Check architecture
      @@arch = `uname -m`
      # Check distribution and version.
      case @@type
      when :Darwin
        @@distro = :Mac_OS_X
        @@version = `sw_vers | grep ProductVersion | cut -d ' ' -f 2`
      when :Linux
        res = `cat /etc/*-release`
        case res
        when /Red Hat Enterprise Linux Server/
          @@distro = :Red_Hat_Enterprise
          @@version = res.match(/\d+\.\d+/)[0]
        when /Ubuntu/
          @@distro = :Ubuntu
          @@version = res.match(/DISTRIB_RELEASE=\d+\.\d+/)[1]
        else
          report_error "Unknown distro \"#{res}\"!"
        end
      end
    end

    def self.x86_64?
      @@arch == 'x86_64'
    end

    def self.shared_library_suffix
      case type
      when :Darwin
        'dylib'
      when :Linux
        'so'
      end
    end
  end
end