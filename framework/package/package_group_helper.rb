module PACKMAN
  class PackageGroupHelper
    def self.inherit_options master_options, slave_package_name
      slave_options = master_options.clone
      if master_options[:use_version]
        # First reset version.
        slave_options[:use_version] = nil
        # Query the version to be used.
        if master_options[:use_version].include? slave_package_name.to_s.downcase
          blocks = master_options[:use_version].split('|')
          blocks.each do |block|
            next if not block.include? slave_package_name.to_s.downcase
            versions = block.split(':')
            slave_options[:use_version] = versions.last
            break
          end
        end
      end
      return slave_options
    end
  end
end
