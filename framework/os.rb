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

    def self.init
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
      @@arch = `uname -m`.chomp
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
          @@version = res.match(/DISTRIB_RELEASE=(\d+\.\d+)/)[1]
        when /Fedora/
          @@distro = :Fedora
          @@version = res.match(/VERSION_ID=(\d+)/)[1]
        when /CentOS/
          @@distro = :CentOS
          @@version = res.match(/release (\d+.\d+)/)[1]
        else
          PACKMAN.report_error "Unknown distro \"#{res}\"!"
        end
      end
    end

    def self.x86_64?
      @@arch == 'x86_64'
    end

    def self.red_hat_gang?
      if distro == :Red_Hat_Enterprise or
         distro == :Fedora or
         distro == :CentOS
        return true
      else
        return false
      end
    end

    def self.debian_gang?
      if distro == :Ubuntu
        return true
      else
        return false
      end
    end

    def self.mac_gang?
      if distro == :Mac_OS_X
        return true
      else
        return false
      end
    end

    def self.shared_library_suffix
      case type
      when :Darwin
        'dylib'
      when :Linux
        'so'
      else
        PACKMAN.under_construction!
      end
    end

    def self.ld_library_path_name
      case type
      when :Darwin
        'DYLD_LIBRARY_PATH'
      when :Linux
        'LD_LIBRARY_PATH'
      else
        PACKMAN.under_construction!
      end
    end

    def self.installed?(package)
      # NOTE: Since the same package may have different names in different
      # distros, so the argument 'package' is an array with all possible
      # names.
      package = [package] if package.class != Array
      flag = true
      package.each do |p|
        begin
          if debian_gang?
            PACKMAN.slim_run "dpkg-query -l #{p}"
          elsif red_hat_gang?
            PACKMAN.slim_run "rpm -q #{p}"
          elsif mac_gang?
            # TODO: How to handle this branch?
            PACKMAN.under_construction!
          else
            PACKMAN.report_error "Unknown OS!"
          end
        rescue
          flag = false
          break
        end
      end
      return flag
    end

    def self.how_to_install(package)
      res = ''
      package = [package] if package.class != Array
      package.each do |p|
        if debian_gang?
          res << "sudo apt-get install #{p}\n"
        elsif red_hat_gang?
          res << "sudo yum install #{p}\n"
        elsif mac_gang?
          # TODO: How to handle this branch?
          PACKMAN.under_construction!
        else
          PACKMAN.report_error "Unknown OS!"
        end
      end
      return res
    end
  end
end
