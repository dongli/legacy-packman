module PACKMAN
  def self.collect_packages
    package_root = ConfigManager.package_root
    PACKMAN.mkdir(package_root)
    # Download packages to package_root.
    ConfigManager.packages.keys.each do |package_name|
      package = eval "#{package_name}.new"
      download_package(package_root, package)
    end
  end

  def self.download_package(package_root, package, is_recursive = false)
    # Recursively download dependency packages.
    package.depends.each do |depend|
      depend_package_name = depend.capitalize
      if not ConfigManager.packages.keys.include? depend_package_name
        depend_package = eval "#{depend_package_name}.new"
        download_package(package_root, depend_package, true)
      end
    end
    # Skip package that is provided by system.
    return if package.labels.include?('should_provided_by_system')
    # Check if there is any patch to download.
    patch_counter = -1
    package.patches.each do |patch|
      patch_counter += 1
      url = patch.first
      sha1 = patch.last
      patch_file = "#{package_root}/#{package.class}.patch.#{patch_counter}"
      if File.exist?(patch_file)
        if PACKMAN.sha1_same?(patch_file, sha1)
          next
        end
      end
      report_notice "Download patch #{url}."
      PACKMAN.download(package_root, url, File.basename(patch_file))
    end
    # Check if there is any attachment to download.
    package.attaches.each do |attach|
      url = attach.first
      sha1 = attach.last
      attach_file = "#{package_root}/#{File.basename(URI.parse(url).path)}"
      if File.exist?(attach_file)
        if PACKMAN.sha1_same?(attach_file, sha1)
          next
        end
      end
      report_notice "Download attachment #{url}."
      PACKMAN.download(package_root, url, File.basename(attach_file))
    end
    # Download current package.
    package.download_to(package_root)
  end
end
