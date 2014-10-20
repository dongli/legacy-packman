module PACKMAN
  class Commands
    def self.collect options = []
      options = [options] if not options.class == Array
      PACKMAN.mkdir ConfigManager.package_root
      # Download packages to package_root.
      collect_all = ( CommandLine.has_option? '-all' or options.include? :all )
      if collect_all
        package_names = Dir.glob("#{ENV['PACKMAN_ROOT']}/packages/*.rb").map { |f| File.basename(f).gsub('.rb', '').capitalize.to_sym }
      else
        package_names = ConfigManager.packages.keys
      end
      package_names.each do |package_name|
        if not collect_all
          install_spec = ConfigManager.packages[package_name]
          package = Package.instance package_name, install_spec
          PACKMAN.download_package package
        else
          all_instances = Package.all_instances package_name
          all_instances.each do |package|
            if all_instances.size == 1
              PACKMAN.download_package package
            elsif all_instances.size > 1
              PACKMAN.download_package package, :multiple_versions
            end
          end
        end
      end
    end
  end

  def self.download_package package, options = []
    options = [options] if not options.class == Array
    # Recursively download dependency packages.
    package.dependencies.each do |depend|
      if not ConfigManager.packages.keys.include? depend
        download_package Package.instance depend
      end
    end
    # Skip the package that should be provided by system.
    return if package.has_label? 'should_provided_by_system'
    # Skip the package that is a master.
    return if package.has_label? 'master_package'
    # Check if there is any patch to download.
    patch_counter = -1
    package.patches.each do |patch|
      patch_counter += 1
      url = patch.url
      patch_file_name = "#{package.class}.patch.#{patch_counter}"
      patch_file_path = "#{ConfigManager.package_root}/#{patch_file_name}"
      if File.exist? patch_file_path
        next if PACKMAN.sha1_same? patch_file_path, patch.sha1
      end
      CLI.report_notice "Download patch #{url}."
      if not ConfigManager.use_ftp_mirror == 'no'
        url = "#{ConfigManager.use_ftp_mirror}/#{patch_file_name}"
      end
      PACKMAN.download ConfigManager.package_root, url, patch_file_name
    end
    # Check if there is any attachment to download.
    package.attachments.each do |attach|
      url = attach.url
      attach_file_name = "#{File.basename(URI.parse(url).path)}"
      attach_file_path = "#{ConfigManager.package_root}/#{attach_file_name}"
      if File.exist? attach_file_path
        next if PACKMAN.sha1_same? attach_file_path, attach.sha1
      end
      CLI.report_notice "Download attachment #{url}."
      if not ConfigManager.use_ftp_mirror == 'no'
        url = "#{ConfigManager.use_ftp_mirror}/#{attach_file_name}"
      end
      PACKMAN.download ConfigManager.package_root, url, attach_file_name
    end
    # Download current package.
    if package.respond_to? :url
      package_file_path = "#{ConfigManager.package_root}/#{package.filename}"
      if File.exist? package_file_path
        return if PACKMAN.sha1_same? package_file_path, package.sha1
      end
      if options.include? :multiple_versions
        CLI.report_notice "Download package #{CLI.red package.class} (#{package.filename})."
      else
        CLI.report_notice "Download package #{CLI.red package.class}."
      end
      url = package.url
      if not ConfigManager.use_ftp_mirror == 'no'
        url = "#{ConfigManager.use_ftp_mirror}/#{package.filename}"
      end
      PACKMAN.download ConfigManager.package_root, url, package.filename
    elsif package.respond_to? :git
      package_dir_path = "#{ConfigManager.package_root}/#{package.dirname}"
      if Dir.exist? package_dir_path
        return if PACKMAN.sha1_same? package_dir_path, package.sha1
      end
      if options.include? :multiple_versions
        CLI.report_notice "Download package #{CLI.red package.class} (#{package.dirname})."
      else
        CLI.report_notice "Download package #{CLI.red package.class}."
      end
      if not ConfigManager.use_ftp_mirror == 'no'
        url = "#{ConfigManager.use_ftp_mirror}/#{package.dirname}"
        PACKMAN.download ConfigManager.package_root, url, package.dirname
      else
        PACKMAN.git_clone ConfigManager.package_root, package.git, package.tag, package.dirname
      end
    end
  end
end
