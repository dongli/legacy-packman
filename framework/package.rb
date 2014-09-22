module PACKMAN
  class Package
    attr_reader :stable, :devel, :binary, :history_versions
    attr_reader :history_binary_versions, :active_spec

    def initialize requested_spec = nil
      hand_over_spec :stable
      hand_over_spec :devel
      hand_over_spec :binary
      hand_over_spec :history_versions
      hand_over_spec :history_binary_versions

      set_active_spec requested_spec
    end

    def hand_over_spec name
      return if not self.class.class_variable_defined? :"@@#{self.class}_#{name}"
      spec = self.class.class_variable_get :"@@#{self.class}_#{name}"
      instance_variable_set "@#{name}", spec
    end

    def set_active_spec requested_spec
      if requested_spec
        if self.respond_to? requested_spec
          @active_spec = self.send requested_spec
        else
          found = false
          if requested_spec.to_s =~ /@/ and @history_binary_versions
            expected_package_version = requested_spec.to_s.split('@')[0]
            check_hash = @history_binary_versions
          elsif @binary
            expected_package_version = nil
            check_hash = @binary
          end
          if check_hash.has_key? requested_spec
            @active_spec = check_hash[requested_spec]
            return
          end
          check_hash.each do |key, value|
            key.to_s.split('|').each do |version_distro_version|
              tmp1 = version_distro_version.split('@')
              package_version = tmp1.first
              next if expected_package_version and package_version != expected_package_version
              tmp2 = tmp1.last.split(':')
              distro = tmp2.first.to_sym
              next if not distro == PACKMAN::OS.distro
              tmp3 = tmp2.last.match(/(>=|==|=~)?\s*(.*)/)
              operator = tmp3[1] rescue '=='
              v1 = PACKMAN::VersionSpec.new tmp3[2]
              v2 = PACKMAN::OS.version
              if eval "v2 #{operator} v1"
                found = true
                @active_spec = value
                break
              end
            end
            break if found
          end
          if not found
            PACKMAN::CLI.report_error "Can not find requested package spec #{requested_spec}!"
          end
        end
      else
        @active_spec = stable || devel
      end
    end

    def url; @active_spec.url; end
    def sha1; @active_spec.sha1; end
    def version; @active_spec.version; end
    def filename; @active_spec.filename; end
    def labels; @active_spec.labels; end
    def has_label? val; @active_spec.has_label? val; end
    def conflict_packages; @active_spec.conflict_packages; end
    def conflict_with? val; @active_spec.conflict_with? val; end
    def dependencies; @active_spec.dependencies; end
    def patches; @active_spec.patches; end
    def embeded_patches; @active_spec.embeded_patches; end
    def attachments; @active_spec.attachments; end
    def provided_stuffs; @active_spec.provided_stuffs; end
    def binary distro, version; @binary[:"#{distro}:#{version}"]; end
    def skip_distros; @active_spec.skip_distros; end
    def options; @active_spec.options; end

    def all_specs
      specs = []
      specs << :stable if stable
      specs << :devel if devel
      specs += @binary.keys if @binary
      specs += @history_versions.keys if @history_versions
      specs += @history_binary_versions.keys if @history_binary_versions
      return specs
    end

    # Package DSL.
    class << self
      def url val; stable.url val; end
      def sha1 val; stable.sha1 val; end
      def version val; stable.version val; end
      def filename val; stable.filename val; end
      def label val; stable.label val; end
      def conflicts_with val; stable.conflicts_with val; end
      def depends_on val; stable.depends_on val; end
      def provide val; stable.provide val; end
      def skip_on val; stable.skip_on val; end
      def option key; stable.option key; end
      def options; stable.options; end

      def patch option = nil, &block
        if option == :embed
          data = ''
          start = false
          File.open("#{ENV['PACKMAN_ROOT']}/packages/#{self.to_s.downcase}.rb", 'r').each do |line|
            if line =~ /__END__/
              start = true
              next
            end
            if start
              data << line
            end
          end
          stable.patch_embed data
        elsif block_given?
          stable.patch &block
        end
      end

      def attach option = nil, &block
        stable.attach &block
        if option == :for_all
          devel.attach &block if devel
          if binary
            binary.each_value do |b|
              b.attach &block
            end
          end
        end
      end

      def stable; eval "@@#{self}_stable ||= PackageSpec.new"; end

      def devel &block
        eval "@@#{self}_devel ||= PackageSpec.new"
        if block_given?
          eval "@@#{self}_devel.instance_eval &block"
        else
          return eval "@@#{self}_devel"
        end
      end

      def binary distros = nil, versions = nil, &block
        eval "@@#{self}_binary ||= {}"
        return eval "@@#{self}_binary" if not distros and not versions
        distros = [distros] if not distros.class == Array
        versions = [versions] if not versions.class == Array
        key = []
        for i in 0..distros.size-1
          PACKMAN::VersionSpec.validate versions[i]
          key << "#{distros[i]}:#{versions[i]}"
        end
        key = key.join('|').to_sym
        if block_given?
          eval "@@#{self}_binary[key] = PackageSpec.new"
          eval "@@#{self}_binary[key].instance_eval &block"
          eval "@@#{self}_binary[key].label 'binary'"
        else
          eval "@@#{self}_binary[key]"
        end
      end

      def history_version version, &block
        eval "@@#{self}_history_versions ||= {}"
        if block_given?
          eval "@@#{self}_history_versions[version] = PackageSpec.new"
          eval "@@#{self}_history_versions[version].instance_eval &block"
          eval "@@#{self}_history_versions[version].version version"
        else
          PACKMAN::CLI.report_error "No block is given!"
        end
      end

      def history_binary_version version, distros = nil, versions = nil, &block
        eval "@@#{self}_history_binary_versions ||= {}"
        distros = [distros] if not distros.class == Array
        versions = [versions] if not versions.class == Array
        key = []
        for i in 0..distros.size-1
          PACKMAN::VersionSpec.validate versions[i]
          key << "#{version}@#{distros[i]}:#{versions[i]}"
        end
        key = key.join('|').to_sym
        if block_given?
          eval "@@#{self}_history_binary_versions[key] = PackageSpec.new"
          eval "@@#{self}_history_binary_versions[key].instance_eval &block"
          eval "@@#{self}_history_binary_versions[key].version version"
          eval "@@#{self}_history_binary_versions[key].label 'binary'"
        else
          PACKMAN::CLI.report_error "No block is given!"
        end
      end
    end

    def self.defined? package_name
      File.exist? "#{ENV['PACKMAN_ROOT']}/packages/#{package_name.downcase}.rb"
    end

    def self.instance package_name, install_spec = {}
      begin
        if install_spec['use_binary']
          if install_spec['version']
            eval "#{package_name}.new :'#{install_spec['version']}@#{PACKMAN::OS.distro}:#{PACKMAN::OS.version}'"
          else
            eval "#{package_name}.new :'#{PACKMAN::OS.distro}:#{PACKMAN::OS.version}'"
          end
        else
          eval "#{package_name}.new"
        end
      rescue
        require "#{ENV['PACKMAN_ROOT']}/packages/#{package_name.to_s.downcase}.rb"
        instance package_name, install_spec
      end
    end

    def self.all_instances package_name
      instances = []
      eval("#{package_name}.new").all_specs.each do |spec|
        instances << eval("#{package_name}.new spec")
      end
      return instances
    end

    def self.apply_patch(package)
      for i in 0..package.patches.size-1
        patch_file = "#{ConfigManager.package_root}/#{package.class}.patch.#{i}"
        PACKMAN.run "patch -N -Z -p1 < #{patch_file}"
        if not $?.success?
          PACKMAN::CLI.report_error "Failed to apply patch for #{PACKMAN::CLI.red package.class}!"
        end
      end
      package.embeded_patches.each do |patch|
        PACKMAN::CLI.report_notice "Apply embeded patch."
        IO.popen("/usr/bin/patch --ignore-whitespace -N -Z -p1", "w") { |p| p.write(patch) }
        if not $?.success?
          PACKMAN::CLI.report_error "Failed to apply embeded patch for #{PACKMAN::CLI.red package.class}!"
        end
      end
    end

    def postfix; end

    def skip?
      skip_distros.include? PACKMAN::OS.distro or
      skip_distros.include? :all or
      labels.include? 'should_provided_by_system' or
      ( labels.include? 'use_system_first' and installed? )
    end

    def decompress_to(root)
      PACKMAN::CLI.report_notice "Decompress #{filename}."
      if not File.exist? "#{root}/#{filename}"
        PACKMAN::CLI.report_error "Package #{CLI.red self.class} has not been downloaded!"
      end
      decom_dir = "#{root}/#{self.class}"
      PACKMAN.mkdir(decom_dir, :force)
      PACKMAN.cd decom_dir
      PACKMAN.decompress "#{root}/#{filename}"
      PACKMAN.cd_back
    end

    def copy_to(root)
      PACKMAN::CLI.report_notice "Copy #{dirname}."
      if not Dir.exist? "#{root}/#{dirname}"
        PACKMAN::CLI.report_error "Package #{CLI.red self.class} has not been downloaded!"
      end
      copy_dir = "#{root}/#{self.class}"
      PACKMAN.mkdir(copy_dir, :force)
      PACKMAN.cp "#{root}/#{dirname}", copy_dir
    end

    def self.prefix package, options = []
      options = [options] if not options.class == Array
      if package.class == Class or package.class == String
        package = PACKMAN::Package.instance package
      end
      prefix = "#{ConfigManager.install_root}/#{package.class.to_s.downcase}/#{package.version}"
      if not package.has_label? 'compiler' and
        not package.has_label? 'compiler_insensitive' and
        not options.include? :compiler_insensitive
        compiler_set_index = ConfigManager.compiler_sets.index(Package.compiler_set)
        prefix << "/#{compiler_set_index}"
      end
      return prefix
    end

    def self.compiler_set
      @@compiler_set
    end

    def self.compiler_set=(val)
      @@compiler_set = val
    end

    def self.bashrc(package, options = [])
      options = [options] if not options.class == Array
      prefix = prefix package, options
      class_name = package.class.name.upcase
      root = "#{class_name}_ROOT"
      open("#{prefix}/bashrc", "w") do |file|
        file << "# #{package.sha1}\n"
        file << "export #{root}=#{prefix}\n"
        if Dir.exist?("#{prefix}/bin")
          file << "export PATH=${#{root}}/bin:${PATH}\n"
        end
        if Dir.exist?("#{prefix}/sbin")
          file << "export PATH=${#{root}}/sbin:${PATH}\n"
        end
        if Dir.exist?("#{prefix}/share/man")
          file << "export MANPATH=\"${#{root}}/share/man:${MANPATH}\"\n"
        end
        if Dir.exist?("#{prefix}/include")
          file << "export #{class_name}_INCLUDE=\"-I${#{root}}/include\"\n"
        end
        libs = []
        if Dir.exist?("#{prefix}/lib")
          libs << "#{prefix}/lib"
        end
        if Dir.exist?("#{prefix}/lib64")
          libs << "#{prefix}/lib64"
        end
        if not libs.empty?
          file << "export #{class_name}_LIBRARY=\"-L#{libs.join(' -L')}\"\n"
          file << "export #{PACKMAN::OS.ld_library_path_name}=\"#{libs.join(':')}:${#{PACKMAN::OS.ld_library_path_name}}\"\n"
          file << "export #{class_name}_RPATH=\"#{libs.join(':')}\"\n"
        end
        if Dir.exist?("#{prefix}/lib/pkgconfig")
          file << "export PKG_CONFIG_PATH=\"${#{root}}/lib/pkgconfig:${PKG_CONFIG_PATH}\"\n"
        end
      end
    end

    def self.default_cmake_args(package)
      %W[
        -DCMAKE_INSTALL_PREFIX=#{prefix(package)}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_FIND_FRAMEWORK=LAST
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -Wno-dev
      ]
    end

    def create_cmake_config(name, include_dirs, libraries)
      prefix = Package.prefix(self)
      if not Dir.exist? "#{prefix}/include" or not Dir.exist? "#{prefix}/lib"
        PACKMAN::CLI.report_error "Nonstandard package #{PACKMAN::CLI.red self.class} without \"include\" or \"lib\" directories!"
      end
      if Dir.exist? "#{prefix}/lib/cmake"
        PACKMAN::CLI.report_error "Cmake configure file has alreadly been installed for #{PACKMAN::CLI.red self.class}!"
      end
      PACKMAN.mkdir "#{prefix}/lib/cmake"
      File.open("#{prefix}/lib/cmake/#{self.class.to_s.downcase}-config.cmake", 'w') do |file|
        file << "set (#{name}_INCLUDE_DIRS"
        case include_dirs.class
        when Array
          include_dirs.each { |dir| file << " #{dir}" }
        when String
          file << include_dirs
        end
        file << ")\n"
        file << "set (#{name}_LIBRARIES"
        case libraries.class
        when Array
          libraries.each { |lib| file << " #{lib}" }
        when String
          file << libraries
        end
        file << ")\n"
      end
    end

    def install_method
      "Not available!"
    end

    def self.install compiler_sets, package, is_recursive = false
      # Check dependencies.
      package.dependencies.each do |depend|
        depend_package = PACKMAN::Package.instance depend.capitalize
        install compiler_sets, depend_package, true
        if not depend_package.skip?
          RunManager.append_bashrc_path("#{prefix(depend_package)}/bashrc")
        end
      end
      # Check if the package should be skipped.
      if package.skip?
        if not package.skip_distros.include? :all and not package.installed?
          PACKMAN::CLI.report_error "Package #{PACKMAN::CLI.red package.class} "+
            "should be provided by system!\n#{PACKMAN::CLI.blue '==>'} "+
            "The possible installation method is:\n#{package.install_method}"
        end
        return
      end
      # Install package.
      if compiler_sets.empty?
        prefix = prefix package, :compiler_insensitive
        # Check if the package has alreadly installed.
        bashrc = "#{prefix}/bashrc"
        if File.exist?(bashrc)
          f = File.new(bashrc, 'r')
          first_line = f.readline
          if first_line =~ /#{package.sha1}/
            if not is_recursive
              PACKMAN::CLI.report_notice "Package #{PACKMAN::CLI.green package.class} has been installed."
            end
            return
          end
          f.close
        end
        # Use precompiled binary file.
        PACKMAN::CLI.report_notice "Use precompiled binary files for #{PACKMAN::CLI.green package.class}."
        PACKMAN.mkdir prefix, :force
        PACKMAN.cd prefix
        package_file = "#{ConfigManager.package_root}/#{package.filename}"
        if not File.exist? package_file
          PACKMAN::CLI.report_error "Precompiled file #{PACKMAN::CLI.red package.filename} has not been downloaded!"
        end
        PACKMAN.decompress package_file
        PACKMAN.cd_back
        # Write bashrc file for the package.
        bashrc package, :compiler_insensitive
        package.postfix
      else
        # Build package for each compiler set.
        compiler_sets.each do |compiler_set|
          @@compiler_set = compiler_set
          # Check if the package has alreadly installed.
          bashrc = "#{prefix(package)}/bashrc"
          if File.exist?(bashrc)
            f = File.new(bashrc, 'r')
            first_line = f.readline
            if first_line =~ /#{package.sha1}/
              if not is_recursive
                PACKMAN::CLI.report_notice "Package #{PACKMAN::CLI.green package.class} has been installed."
              end
              next
            end
            f.close
          end
          # Decompress package file.
          if package.respond_to? :filename
            package.decompress_to ConfigManager.package_root
          elsif package.respond_to? :dirname
            package.copy_to ConfigManager.package_root
          end
          tmp = Dir.glob("#{ConfigManager.package_root}/#{package.class}/*")
          if tmp.size != 1 or not File.directory?(tmp.first)
            tmp = ["#{ConfigManager.package_root}/#{package.class}"]
          end
          build_dir = tmp.first
          PACKMAN.cd build_dir
          # Apply patches.
          apply_patch(package)
          # Install package.
          PACKMAN::CLI.report_notice "Install package #{CLI.green package.class}."
          package.install
          PACKMAN.cd_back
          FileUtils.rm_rf("#{build_dir}")
          # Write bashrc file for the package.
          bashrc(package)
          package.postfix
        end
      end
      # Clean build files.
      if Dir.exist? "#{ConfigManager.package_root}/#{package.class}"
        FileUtils.rm_rf "#{ConfigManager.package_root}/#{package.class}"
      end
      # Clean the bashrc pathes.
      if not is_recursive
        RunManager.clean_bashrc_path
      end
    end
  end
end
