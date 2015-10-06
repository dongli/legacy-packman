module PACKMAN
  class Package
    include PackageDSL
    include PackageShortcuts
    include PackageTransferMethods
    include PackageDefaultMethods
    include PackageBinary

    attr_reader :stable, :binary, :history, :active_spec

    def initialize requested_spec = nil
      # TODO: Avoid unnecessary instances.
      hand_over_spec :stable
      hand_over_spec :binary
      hand_over_spec :history
      inherit_spec :stable, :binary
      inherit_spec :stable, :history
      set_active_spec requested_spec

      # Define short-hand methods for package options.
      for i in 0..active_spec.options.size-1
        option_name = active_spec.options.keys[i]
        option_type = active_spec.option_valid_types[active_spec.options.keys[i]]
        create_option_shortcut option_name, option_type, self, :active_spec
      end

      active_spec.attachments.each_key do |attach_name|
        create_attachment_shortcut attach_name, self, :active_spec
      end
    end

    def hand_over_spec name
      return if not self.class.class_variable_defined? :"@@#{self.name}_#{name}"
      spec = self.class.class_variable_get :"@@#{self.name}_#{name}"
      instance_variable_set "@#{name}", spec
    end

    def inherit_spec master_name, slave_name
      return if not self.class.class_variable_defined? :"@@#{self.name}_#{master_name}"
      return if not self.class.class_variable_defined? :"@@#{self.name}_#{slave_name}"
      master_spec = self.class.class_variable_get :"@@#{self.name}_#{master_name}"
      tmp = self.class.class_variable_get :"@@#{self.name}_#{slave_name}"
      if tmp.class == Array
        slave_specs = tmp
      elsif tmp.class == Hash
        slave_specs = tmp.values
      elsif tmp.class == PACKMAN::PackageSpec
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
          if requested_spec[:binary]
            @active_spec = match_binary
          elsif requested_spec[:history]
            if @history
              @history.each do |version, history_spec|
                if version == requested_spec[:version]
                  @active_spec = history_spec
                  break
                end
              end
            end
            if not @active_spec and stable.version == requested_spec[:version]
              @active_spec = stable
            end
          end
        elsif requested_spec.class == Symbol
          if self.respond_to? requested_spec
            @active_spec = self.send requested_spec
          end
        end
      else
        @active_spec = stable
      end
      if not @active_spec
        CLI.report_error "Unknown requested_spec #{CLI.red requested_spec} for package #{PACKMAN.red name}!"
      end
    end

    def name; PackageAlias.antialias self.class, :downcase; end

    def self.defined? package_name
      File.exist? "#{ENV['PACKMAN_ROOT']}/packages/#{package_name.downcase}.rb"
    end

    def self.instance package_name, options = nil
      options = PackageLoader.package_options package_name if options == nil
      name = PackageAlias.antialias package_name, :downcase
      begin
        requested_spec = {}
        if options[:use_binary]
          requested_spec[:binary] = true
        elsif options[:use_version]
          requested_spec[:history] = true
          requested_spec[:version] = options[:use_version]
        end
        requested_spec = nil if requested_spec.empty?
        package = eval "#{PACKMAN.alias package_name}.new requested_spec"
        # Propagete the given options.
        options.each { |key, value| package.update_option key, value, true }
        return package
      rescue NameError => e
        if e.class == NoMethodError
          CLI.report_error "Encounter error while instancing package!\n"+
            "#{CLI.red '==>'} #{e}"
        end
        load "#{ENV['PACKMAN_ROOT']}/packages/#{name}.rb"
        instance package_name, options
      end
    end

    def self.all_instances package_name
      begin
        instances = []
        instances << eval("#{package_name}.new :stable")
        if self.class_variable_defined? "@@#{package_name}_binary"
          eval("@@#{package_name}_binary").each do ||
            # TODO: Check if we need to set version here.
            requested_spec[:use_version] = value.version
            requested_spec[:key] = key
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
        patch_file = "#{ConfigManager.package_root}/#{package.name}.patch.#{i}"
        PACKMAN.run "patch --ignore-whitespace -N -p1 < #{patch_file}"
        if not $?.success?
          CLI.report_error "Failed to apply patch for #{CLI.red package.name}!"
        end
      end
      package.embeded_patches.each do |patch|
        CLI.report_notice "Apply embeded patch."
        file = File.new('packman_embed_patch', 'w')
        file << patch
        file.close
        PACKMAN.run "patch --ignore-whitespace -N -p1 < packman_embed_patch"
        if not $?.success?
          CLI.report_error "Failed to apply embeded patch for #{CLI.red package.name}!"
        end
      end
    end

    def should_be_skipped?
      has_label? :skipped or (has_label? :try_system_package_first and installed?)
    end

    def is_compressed?
      return false if respond_to? :dirname
      PACKMAN.compression_type filename, :not_exit
    end

    def decompress_to root
      if not File.exist? "#{ConfigManager.package_root}/#{filename}"
        CLI.report_error "Package #{CLI.red name} has not been downloaded!"
      end
      if root == ConfigManager.package_root
        dir = "#{root}/#{name}"
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
        CLI.report_error "Package #{CLI.red name} has not been downloaded!"
      end
      copy_dir = "#{root}/#{self.class}"
      PACKMAN.mkdir copy_dir, :force, :silent
      PACKMAN.cp "#{root}/#{file}", copy_dir
    end
  end

  def self.prefix package, *options
    package = Package.instance package if package.class == Class or package.class == Symbol
    if package.methods.include? :system_prefix and package.system_prefix
      prefix = package.system_prefix
    else
      prefix = "#{ConfigManager.install_root}/#{package.name}/#{package.version}"
      if not package.has_label? :compiler_insensitive
        PACKMAN.report_error 'No active compiler set is set!' if not CompilerManager.active_compiler_set_index
        prefix << "/#{CompilerManager.active_compiler_set_index}"
      end
    end
    prefix
  end
end
