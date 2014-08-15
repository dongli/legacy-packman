module PACKMAN
  def self.collect_packages(config_manager)
    package_root = config_manager.get_value('packman', 'package_root')
    config_manager.get_keys('packman').each do |key|
      if key =~ /^package_.*/
        package_name = key.to_s.gsub(/^package_/, '').capitalize
        next if not PACKMAN.class_defined?(package_name)
        package = eval "#{package_name}.new"
        package_file = "#{package_root}/#{package.filename}"
        if File.exist?(package_file)
          if PACKMAN.sha1_same?(package_file, package.sha1)
            report_notice "Package #{Tty.green}#{package_name}#{Tty.reset} is already downloaded."
            next
          end
        end
        report_notice "Download package #{Tty.red}#{package_name}#{Tty.reset}."
        package.download_to(package_root)
      end
    end
  end
end
