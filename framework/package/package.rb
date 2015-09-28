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

      inherit_spec :stable, :devel
      inherit_spec :stable, :history_versions

      set_active_spec requested_spec

      if active_spec.has_label? :installed_with_source and not active_spec.has_label? :not_use_target_dir_option
        active_spec.option 'target_dir' => :directory
      end

      # Define short-hand method for package options.
      for i in 0..active_spec.options.size-1
        option_name = active_spec.options.keys[i]
        option_type = active_spec.option_valid_types[active_spec.options.keys[i]]
        PackageDslHelper.create_option_shortcut option_name, option_type, self, :active_spec
      end

      active_spec.attachments.each_key do |attach_name|
        PackageDslHelper.create_attachment_shortcut attach_name, self, :active_spec
      end
    end

    def hand_over_spec name
      return if not self.class.class_variable_defined? :"@@#{self.class}_#{name}"
      spec = self.class.class_variable_get :"@@#{self.class}_#{name}"
      instance_variable_set "@#{name}", spec
    end

    def inherit_spec master_name, slave_name
      return if not self.class.class_variable_defined? :"@@#{self.class}_#{master_name}"
      return if not self.class.class_variable_defined? :"@@#{self.class}_#{slave_name}"
      master_spec = self.class.class_variable_get :"@@#{self.class}_#{master_name}"
      tmp = self.class.class_variable_get :"@@#{self.class}_#{slave_name}"
      if tmp.class == Hash
        slave_specs = tmp.values
      elsif tmp.class == PACKMAN::PackageAtom
        slave_specs = [tmp]
      end
      slave_specs.each do |slave_spec|
        slave_spec.inherit master_spec
      end
    end

    def set_active_spec requested_spec
      @active_spec = nil
      if requested_spec
        if requested_spec.class == Hash
          case requested_spec[:in]
          when :devel
            @active_spec = devel
          when :history_versions
            if not history_versions.has_key? requested_spec[:use_version]
              if @stable and stable.version == requested_spec[:use_version]
                @active_spec = stable
              elsif @devel and devel.version == requested_spec[:use_version]
                @active_spec = devel
              else
                CLI.report_error "There is no #{CLI.red requested_spec[:use_version]} in "+
                  "#{CLI.red self.class}!"
              end
            else
              @active_spec = history_versions[requested_spec[:use_version]]
            end
          when :binary
            @binary.each do |key, value|
              if requested_spec.has_key? :key
                # TODO: Should we judge version here? Because there should be
                # only one version in the binary.
                if requested_spec[:key] == key and requested_spec[:use_version] == value.version
                  @active_spec = value
                  break
                end
              else
                key.to_s.split('|').each do |split_key|
                  tmp1 = split_key.split(':')
                  next if PACKMAN.os.type != tmp1.first.to_sym
                  tmp2 = tmp1.last.match(/(>=|==|=~)?\s*(.*)/)
                  operator = tmp2[1] ? tmp2[1] : '=='
                  v1 = VersionSpec.new tmp2[2]
                  v2 = PACKMAN.os.version
                  if eval "v2 #{operator} v1"
                    @active_spec = value
                    break
                  end
                end
                break if @active_spec
              end
            end
          when :history_binary_versions
            @history_binary_versions.each do |key, value|
              if requested_spec.has_key? :key
                if requested_spec[:key] == key
                  @active_spec = value
                  break
                end
              else
                key.to_s.split('|').each do |x|
                  tmp1 = x.split('@')
                  package_version = tmp1.first
                  next if package_version != requested_spec[:use_version]
                  tmp2 = tmp1.last.split(':')
                  next if PACKMAN.os.type != tmp2.first.to_sym
                  tmp3 = tmp2.last.match(/(>=|==|=~)?\s*(.*)/)
                  operator = tmp3[1] ? tmp3[1] : '=='
                  v1 = VersionSpec.new tmp3[2]
                  v2 = PACKMAN.os.version
                  if eval "v2 #{operator} v1"
                    @active_spec = value
                    break
                  end
                end
                break if @active_spec
              end
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
        CLI.report_error "Unknown requested_spec #{CLI.red requested_spec} for package #{PACKMAN.red self.class}!"
      end
    end

    def url; @active_spec.url; end
    def sha1; @active_spec.sha1; end
    def version; @active_spec.version; end
    def revision; @active_spec.revision; end
    def filename; @active_spec.filename; end
    def package_path; @active_spec.package_path; end
    def labels; @active_spec.labels; end
    def has_label? val; @active_spec.has_label? val; end
    def conflict_packages; @active_spec.conflict_packages; end
    def conflict_reasons; @active_spec.conflict_reasons; end
    def conflict_with? val; @active_spec.conflict_with? val; end
    def dependencies; @active_spec.dependencies; end
    def master_package; @active_spec.master_package; end
    def patches; @active_spec.patches; end
    def embeded_patches; @active_spec.embeded_patches; end
    def attachments; @active_spec.attachments; end
    def provided_stuffs; @active_spec.provided_stuffs; end
    def binary distro, version; @binary[:"#{distro}:#{version}"]; end
    def option_valid_types; @active_spec.option_valid_types; end
    def options; @active_spec.options; end
    def has_option? key; @active_spec.has_option? key; end
    def update_option key, value, ignore_error = false
      return if key == 'use_binary' and not has_binary?
      @active_spec.update_option key, value, ignore_error
    end
    def has_binary?; defined?(@binary) != nil; end

    # Shortcuts.
    def prefix; PACKMAN.prefix self; end
    def bin; prefix+'/bin'; end
    def sbin; prefix+'/sbin'; end
    def etc; prefix+'/etc'; end
    def include; prefix+'/include'; end
    def lib; prefix+'/lib'; end
    def libexec; prefix+'/libexec'; end
    def share; prefix+'/share'; end
    def doc; share+'/doc/'+self.class.to_s.downcase; end
    def man; share+'/man'; end
    def var; prefix+'/var'; end
    def frameworks; prefix+'/Frameworks'; end
    def info; prefix+'/packman.info'; end
    def self.prefix; PACKMAN.prefix self; end
    def self.bin; prefix+'/bin'; end
    def self.sbin; prefix+'/sbin'; end
    def self.etc; prefix+'/etc'; end
    def self.include; prefix+'/include'; end
    def self.lib; prefix+'/lib'; end
    def self.libexec; prefix+'/libexec'; end
    def self.share; prefix+'/share'; end
    def self.doc; share+'/doc/'+self.class.to_s.downcase; end
    def self.man; share+'/man'; end
    def self.frameworks; prefix+'/Frameworks'; end
    def self.info; prefix+'/packman.info'; end
    def self.var; prefix+'/var'; end

    # Package DSL.
    class << self
      def url val; stable.url val; end
      def sha1 val; stable.sha1 val; end
      def version val = nil; stable.version val; end
      def filename val; stable.filename val; end
      def label val; stable.label val; end
      def conflicts_with val, &block; stable.conflicts_with val, &block; end
      def depends_on val, condition = true; stable.depends_on val, condition; end
      def belongs_to val; stable.belongs_to val; end
      def provide val; stable.provide val; end
      def option option_hash
        stable.option option_hash
        option_name = option_hash.keys.first
        option_type = stable.option_valid_types[option_name]
        PackageDslHelper.create_option_shortcut option_name, option_type, self, :"@@#{self}_stable", true
      end
      def revision val; stable.revision val; end

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

      def attach name, option = nil, &block
        stable.attach name, &block
        if option == :for_all
          devel.attach name, &block if devel
          if binary
            binary.each_value do |b|
              b.attach name, &block
            end
          end
        end
      end

      def stable; eval "@@#{self}_stable ||= PackageAtom.new"; end

      def devel &block
        eval "@@#{self}_devel ||= PackageAtom.new"
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
          VersionSpec.validate versions[i]
          key << "#{distros[i]}:#{versions[i]}"
        end
        key = key.join('|').to_sym
        if block_given?
          eval "@@#{self}_binary[key] = PackageAtom.new"
          eval "@@#{self}_binary[key].instance_eval &block"
          eval "@@#{self}_binary[key].label :binary"
        else
          eval "@@#{self}_binary[key]"
        end
      end

      def history_version version, &block
        eval "@@#{self}_history_versions ||= {}"
        if block_given?
          eval "@@#{self}_history_versions[version] = PackageAtom.new"
          eval "@@#{self}_history_versions[version].instance_eval &block"
          eval "@@#{self}_history_versions[version].version version"
        else
          CLI.report_error "No block is given!"
        end
      end

      def history_binary_version version, distros = nil, versions = nil, &block
        eval "@@#{self}_history_binary_versions ||= {}"
        distros = [distros] if not distros.class == Array
        versions = [versions] if not versions.class == Array
        key = []
        for i in 0..distros.size-1
          VersionSpec.validate versions[i]
          key << "#{version}@#{distros[i]}:#{versions[i]}"
        end
        key = key.join('|').to_sym
        if block_given?
          eval "@@#{self}_history_binary_versions[key] = PackageAtom.new"
          eval "@@#{self}_history_binary_versions[key].instance_eval &block"
          eval "@@#{self}_history_binary_versions[key].version version"
          eval "@@#{self}_history_binary_versions[key].label :binary"
        else
          CLI.report_error "No block is given!"
        end
      end
    end

    def self.defined? package_name
      File.exist? "#{ENV['PACKMAN_ROOT']}/packages/#{package_name.downcase}.rb"
    end

    def self.instance package_name, options = nil
      options = PackageLoader.package_options package_name if options == nil
      begin
        requested_spec = {}
        if options['use_binary']
          if options['use_version']
            requested_spec[:use_version] = options['use_version']
            if eval "defined? @@#{package_name}_binary"
              eval("@@#{package_name}_binary").each do |key, value|
                if value.version == requested_spec[:use_version]
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
        elsif options['use_version']
          if eval "defined? @@#{package_name}_history_versions"
            requested_spec[:in] = :history_versions
            requested_spec[:use_version] = options['use_version']
          elsif not eval "@@#{package_name}_stable.has_label? :master_package"
            if "#{eval "@@#{package_name}_stable.version"}" != options['use_version']
              PACKMAN.report_error "Package #{PACKMAN.red package_name} does not have history versions, "+
                "so you cannot set #{PACKMAN.red '-use_version'} or should use "+
                "#{PACKMAN.green '+use_version'} to limit the option scope!"
            end
          end
        elsif options['use_devel']
          requested_spec[:in] = :devel
        end
        requested_spec = nil if requested_spec.empty?
        package = eval "#{PackageAlias.check package_name}.new requested_spec"
        # Propagete the given options.
        options.each { |key, value| package.update_option key, value, true }
        return package
      rescue NameError => e
        if e.class == NoMethodError
          CLI.report_error "Encounter error while instancing package!\n"+
            "#{CLI.red '==>'} #{e}"
        end
        load "#{ENV['PACKMAN_ROOT']}/packages/#{package_name.to_s.downcase}.rb"
        instance package_name, options
      end
    end

    def self.all_instances package_name
      begin
        instances = []
        instances << eval("#{package_name}.new :stable")
        instances << eval("#{package_name}.new :devel") if eval "defined? @@#{package_name}_devel"
        requested_spec = {}
        if self.class_variable_defined? "@@#{package_name}_history_versions"
          requested_spec[:in] = :history_versions
          eval("@@#{package_name}_history_versions").each do |key, value|
            requested_spec[:use_version] = value.version
            instances << eval("#{package_name}.new requested_spec")
          end
        end
        if self.class_variable_defined? "@@#{package_name}_binary"
          requested_spec[:in] = :binary
          eval("@@#{package_name}_binary").each do |key, value|
            # TODO: Check if we need to set version here.
            requested_spec[:use_version] = value.version
            requested_spec[:key] = key
            instances << eval("#{package_name}.new requested_spec")
          end
        end
        if self.class_variable_defined? "@@#{package_name}_history_binary_versions"
          requested_spec[:in] = :history_binary_versions
          eval("@@#{package_name}_history_binary_versions").each do |key, value|
            requested_spec[:key] = key
            instances << eval("#{PackageAlias.check package_name}.new requested_spec")
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
          CLI.report_error "Failed to apply patch for #{CLI.red package.class}!"
        end
      end
      package.embeded_patches.each do |patch|
        CLI.report_notice "Apply embeded patch."
        file = File.new('packman_embed_patch', 'w')
        file << patch
        file.close
        PACKMAN.run "patch --ignore-whitespace -N -p1 < packman_embed_patch"
        if not $?.success?
          CLI.report_error "Failed to apply embeded patch for #{CLI.red package.class}!"
        end
      end
    end

    def post_install; end
    def check_consistency; true; end

    def should_be_skipped?
      has_label? :skipped or (has_label? :try_system_package_first and installed?)
    end

    def is_compressed?
      return false if respond_to? :dirname
      PACKMAN.compression_type filename, :not_exit
    end

    def decompress_to root
      if not File.exist? "#{ConfigManager.package_root}/#{filename}"
        CLI.report_error "Package #{CLI.red self.class} has not been downloaded!"
      end
      if root == ConfigManager.package_root
        dir = "#{root}/#{self.class}"
      else
        dir = root
      end
      PACKMAN.mkdir dir, :force, :silent
      PACKMAN.work_in dir do
        PACKMAN.decompress "#{ConfigManager.package_root}/#{filename}"
      end
    end

    def copy_to root
      if self.respond_to? :filename
        file = filename
      elsif self.respond_to? :dirname
        file = dirname
      end
      CLI.report_notice "Copy #{file}."
      if not File.exist? "#{ConfigManager.package_root}/#{file}"
        CLI.report_error "Package #{CLI.red self.class} has not been downloaded!"
      end
      copy_dir = "#{root}/#{self.class}"
      PACKMAN.mkdir copy_dir, :force, :silent
      PACKMAN.cp "#{root}/#{file}", copy_dir
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

    def install_method
      "Not available!"
    end

    def propagate_options_to other
      return if not active_spec.options or active_spec.options.empty?
      for i in 0..other.options.size-1
        key = other.options.keys[i]
        next if not active_spec.options.has_key? key or not active_spec.options[key]
        next if CommandLine.is_option_limited? key, other
        value = active_spec.options[key]
        other.update_option key, value
      end
    end
  end

  def self.prefix package, options = []
    options = [options] if not options.class == Array
    if package.class == Class or package.class == Symbol
      package = Package.instance package
    end
    if package.master_package
      package_ = Package.instance package.master_package
    else
      package_ = package
    end
    if package_.has_label? :installed_with_source
      if not package_.target_dir
        CLI.report_error "Use #{CLI.red '-target_dir'} to specify where to install #{CLI.green package.class}!"
      end
      prefix = package_.target_dir
    elsif package_.methods.include? :system_prefix and package_.system_prefix
      # Package is already installed somewhere else, use it.
      prefix = package_.system_prefix
    else
      prefix = "#{ConfigManager.install_root}/#{package_.class.to_s.downcase}/#{package_.version}"
      if not package_.has_label? :compiler_insensitive and not package_.use_binary?
        compiler_set_index = CompilerManager.active_compiler_set_index
        prefix << "/#{compiler_set_index}"
      end
    end
    return prefix
  end
end
