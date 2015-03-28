module PACKMAN
  class OsManager
    def self.delegated_methods
      [:os_spec, :os_type, :os_version, :x86_64?, :package_managers,
       :linux?, :mac?, :cygwin?, :redhat?, :debian?,
       :shared_library_suffix, :ld_library_path_name,
       :os_installed?, :os_how_to_install]
    end

    def self.init
      res = `uname`
      case res
      when /^Darwin */
        @@spec = Mac.new
      when /^Linux */
        res = `cat /etc/*-release`
        case res
        when /Red Hat Enterprise Linux Server/
          @@spec = RHEL.new
        when /Ubuntu/
          @@spec = Ubuntu.new
        when /Fedora/
          @@spec = Fedora.new
        when /CentOS/
          @@spec = CentOS.new
        when /Debian GNU\/Linux/
          @@spec = Debian.new
        when /SUSE Linux/
          @@spec = Suse.new
        else
          CLI.report_error "Unknown OS type \"#{res}\"!"
        end
      when /^CYGWIN*/
        @@spec = Cygwin.new
      else
        CLI.report_error "Unknown OS type \"#{res}\"!"
      end
    end

    def self.os_spec; @@spec; end
    def self.os_type; @@spec.type; end
    def self.os_version; @@spec.version; end
    def self.x86_64?; @@spec.x86_64?; end
    def self.package_managers; @@spec.package_managers; end
  
    def self.linux?
      [:RHEL, :Fedora, :CentOS, :SUSE, :Debian, :Ubuntu].include? os_type
    end

    def self.mac?
      os_type == :Mac_OS_X
    end

    def self.cygwin?
      os_type == :Cygwin
    end

    def self.redhat?
      [:RHEL, :Fedora, :CentOS, :SUSE].include? os_type
    end

    def self.debian?
      [:Debian, :Ubuntu].include? os_type
    end

    def self.shared_library_suffix
      if linux?
        'so'
      elsif mac?
        'dylib'
      elsif cygwin?
        'dll'
      end
    end

    def self.ld_library_path_name
      if linux?
        'LD_LIBRARY_PATH'
      elsif mac?
        'DYLD_LIBRARY_PATH'
      elsif cygwin?
        'LD_LIBRARY_PATH'
      end
    end

    def self.os_installed? package_names
      package_names = [package_names] if not package_names.class == Array
      res = Array.new(package_names.size, false)
      package_managers.each do |name, detail|
        for i in 0..package_names.size-1
          `#{detail[:query_command]} #{package_names[i]} 1> /dev/null 2>&1`
          res[i] = true if $?.success?
        end
      end
      return res.all?
    end

    def self.os_how_to_install package_names
      package_names = [package_names] if not package_names.class == Array
      res = []
      package_managers.each do |name, detail|
        next if not detail[:install_command]
        res << detail[:install_command]+' '+package_names.join(' ')
      end
      if res.empty?
        res << "There is no package manager to install #{package_names.join(' ')}!"
      end
      return res.join("\nor\n")
    end
  end
end
