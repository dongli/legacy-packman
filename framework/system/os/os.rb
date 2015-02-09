module PACKMAN
  class OS
    def self.init
      res = `uname`
      case res
      when /^Darwin */
        type = :Darwin
      when /^Linux */
        type = :Linux
      when /^CYGWIN*/
        type = :Cygwin
      else
        CLI.report_error "Unknown OS type \"#{res}\"!"
      end
      case type
      when :Darwin
        @@spec = MacSpec.new
      when :Linux
        res = `cat /etc/*-release`
        case res
        when /Red Hat Enterprise Linux Server/
          @@spec = RHELSpec.new
        when /Ubuntu/
          @@spec = UbuntuSpec.new
        when /Fedora/
          @@spec = FedoraSpec.new
        when /CentOS/
          @@spec = CentOSSpec.new
        when /Debian GNU\/Linux/
          @@spec = DebianSpec.new
        when /SUSE Linux/
          @@spec = SuseSpec.new
        else
          CLI.report_error "Unknown distro \"#{res}\"!"
        end
      when :Cygwin
        @@spec = CygwinSpec.new
      end
    end

    def self.type; @@spec.type; end
    def self.distro; @@spec.distro; end
    def self.version; @@spec.version; end
    def self.x86_64?; @@spec.x86_64?; end
    def self.package_managers; @@spec.package_managers; end
    
    def self.redhat_gang?
      if distro == :RHEL or distro == :Fedora or
         distro == :CentOS or distro == :SUSE
        return true
      else
        return false
      end
    end

    def self.debian_gang?
      if distro == :Debian or distro == :Ubuntu
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

    def self.cygwin_gang?
      if distro == :Cygwin
        return true
      else
        return false
      end
    end

    def self.shared_library_suffix
      case type
      when :Linux
        'so'
      when :Darwin
        'dylib'
      when :Cygwin
        'dll'
      end
    end

    def self.ld_library_path_name
      case type
      when :Linux
        'LD_LIBRARY_PATH'
      when :Darwin
        'DYLD_LIBRARY_PATH'
      when :Cygwin
        'LD_LIBRARY_PATH'
      end
    end

    def self.installed? package_names
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

    def self.how_to_install package_names
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
