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
        if requested_spec.class == Hash
          case requested_spec[:in]
          when :history_versions
            if not history_versions.has_key? requested_spec[:version]
              PACKMAN::CLI.report_error "There is no #{PACKMAN::CLI.red requested_spec[:version]} in "+
                "#{PACKMAN::CLI.red self.class}!"
            end
            @active_spec = history_versions[requested_spec[:version]]
          when :binary
            @binary.each do |key, value|
              tmp1 = key.to_s.split(':')
              if requested_spec.has_key? :os_distro
                if requested_spec[:os_distro] == tmp1.first.to_sym
                  @active_spec = value
                  break
                end
              else
                next if PACKMAN::OS.distro != tmp1.first.to_sym
                tmp2 = tmp1.last.match(/(>=|==|=~)?\s*(.*)/)
                operator = tmp2[1] ? tmp2[1] : '=='
                v1 = PACKMAN::VersionSpec.new tmp2[2]
                v2 = PACKMAN::OS.version
                if eval "v2 #{operator} v1"
                  @active_spec = value
                  break
                end
              end
            end
          when :history_binary_versions
            @history_binary_versions.each do |key, value|
              key.to_s.split('|').each do |x|
                tmp1 = x.split('@')
                package_version = tmp1.first
                next if package_version != requested_spec[:version]
                tmp2 = tmp1.last.split(':')
                next if PACKMAN::OS.distro != tmp2.first.to_sym
                tmp3 = tmp2.last.match(/(>=|==|=~)?\s*(.*)/)
                operator = tmp3[1] ? tmp3[1] : '=='
                v1 = PACKMAN::VersionSpec.new tmp3[2]
                v2 = PACKMAN::OS.version
                if eval "v2 #{operator} v1"
                  @active_spec = value
                  break
                end
              end
              break if @active_spec
            end
          end
        elsif requested_spec.class == Symbol
          if self.respond_to? requested_spec
            @active_spec = self.send requested_spec
          end
        end
      else
        @active_spec = stable || devel
      end
      if not @active_spec
        PACKMAN::CLI.report_error "Unknown requested_spec #{PACKMAN::CLI.red requested_spec}!"
      end
    end

    def url; @active_spec.url; end
    def sha1; @active_spec.sha1; end
    def version; @active_spec.version; end
    def filename; @active_spec.filename; end
    def labels; @active_spec.labels; end
    def has_label? val; @active_spec.has_label? val; end
    def conflict_packages; @active_spec.conflict_packages; end
    def conflict_reasons; @active_spec.conflict_reasons; end
    def conflict_with? val; @active_spec.conflict_with? val; end
    def dependencies; @active_spec.dependencies; end
    def patches; @active_spec.patches; end
    def embeded_patches; @active_spec.embeded_patches; end
    def attachments; @active_spec.attachments; end
    def provided_stuffs; @active_spec.provided_stuffs; end
    def binary distro, version; @binary[:"#{distro}:#{version}"]; end
    def skip_distros; @active_spec.skip_distros; end
    def option_valid_types; @active_spec.option_valid_types; end
    def options; @active_spec.options; end
    def has_binary?; defined? @binary; end

    # Package DSL.
    class << self
      def url val; stable.url val; end
      def sha1 val; stable.sha1 val; end
      def version val; stable.version val; end
      def filename val; stable.filename val; end
      def label val; stable.label val; end
      def conflicts_with val, &block; stable.conflicts_with val, &block; end
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
        requested_spec = {}
        if install_spec['use_binary']
          if install_spec['version']
            requested_spec[:version] = install_spec['version']
            if eval "defined? @@#{package_name}_binary"
              eval("@@#{package_name}_binary").each do |key, value|
                if value.version == requested_spec[:version]
                  requested_spec[:in] = :binary
                  break
                end
              end
            end
            if not requested_spec.has_key? :in and eval "defined? @@#{package_name}_history_binary_versions"
              requested_spec[:in] = :history_binary_versions
            end
          else
            requested_spec[:in] = :binary
          end
        elsif install_spec['version']
          if eval "defined? @@#{package_name}_history_versions"
            requested_spec[:in] = :history_versions
            requested_spec[:version] = install_spec['version']
          end
        end
        requested_spec = nil if requested_spec.empty?
        eval "#{package_name}.new requested_spec"
      rescue NameError => e
        if e.class == NoMethodError
          PACKMAN::CLI.report_error "Encounter error while instancing package!\n"+
            "#{PACKMAN::CLI.red '==>'} #{e}"
        end
        load "#{ENV['PACKMAN_ROOT']}/packages/#{package_name.to_s.downcase}.rb"
        instance package_name, install_spec
      end
    end

    def self.all_instances package_name
      begin
        instances = []
        instances << eval("#{package_name}.new :stable") if eval "defined? @@#{package_name}_stable"
        instances << eval("#{package_name}.new :devel") if eval "defined? @@#{package_name}_devel"
        requested_spec = {}
        if self.class_variable_defined? "@@#{package_name}_history_versions"
          requested_spec[:in] = :history_versions
          eval("@@#{package_name}_history_versions").each do |key, value|
            requested_spec[:version] = value.version
            instances << eval("#{package_name}.new requested_spec")
          end
        end
        if self.class_variable_defined? "@@#{package_name}_binary"
          requested_spec[:in] = :binary
          eval("@@#{package_name}_binary").each do |key, value|
            requested_spec[:version] = value.version
            requested_spec[:os_distro] = key.to_s.split(':')[0].to_sym
            instances << eval("#{package_name}.new requested_spec")
          end
        end
        if self.class_variable_defined? "@@#{package_name}_history_binary_versions"
          requested_spec[:in] = :history_binary_versions
          eval("@@#{package_name}_history_binary_versions").each do |key, value|
            requested_spec[:version] = value.version
            requested_spec[:os_distro] = key.to_s.split(':')[0].to_sym
            instances << eval("#{package_name}.new requested_spec")
          end
        end
        return instances
      rescue
        load "#{ENV['PACKMAN_ROOT']}/packages/#{package_name.to_s.downcase}.rb"
        all_instances package_name
      end
    end

    def self.all_package_names
      if not defined? @@all_package_names
        @@all_package_names = []
        Dir.foreach("#{ENV['PACKMAN_ROOT']}/packages") do |file|
          next if not file =~ /.*\.rb$/
          if File.open("#{ENV['PACKMAN_ROOT']}/packages/#{file}").read.match(/\< PACKMAN::Package/)
            @@all_package_names << file.gsub(/\.rb$/, '')
          end
        end
      end
      return @@all_package_names
    end

    def self.apply_patch package
      for i in 0..package.patches.size-1
        patch_file = "#{ConfigManager.package_root}/#{package.class}.patch.#{i}"
        PACKMAN.run "patch --ignore-whitespace -N -p1 < #{patch_file}"
        if not $?.success?
          PACKMAN::CLI.report_error "Failed to apply patch for #{PACKMAN::CLI.red package.class}!"
        end
      end
      package.embeded_patches.each do |patch|
        PACKMAN::CLI.report_notice "Apply embeded patch."
        IO.popen("patch --ignore-whitespace -N -p1", "w") { |p| p.write(patch) }
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

    def self.bashrc package, options = []
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
  end
end
