module PACKMAN
  module Files
    class Info
      def self.write package, *options
        prefix = PACKMAN.prefix package, options
        if not Dir.exist? prefix
          CLI.report_error "Package #{CLI.red package.class} has not been installed!"
        end
        if package.master_package
          class_name = package.master_package.to_s.upcase
        else
          class_name = package.class.name.upcase
        end
        info = "#{prefix}/packman.info"
        if File.exist? info
          content = File.open(info, 'r').read
          slave_package_tags = content.scan(/^# (\w+) (\w{40}) ?(\d+)?$/)
        end
        File.open(info, 'w') do |file|
          # Write package tag or tags.
          if package.master_package and slave_package_tags
            tmp = package.class.name.upcase.to_sym
            slave_package_tags.each do |tag|
              if tag.first.to_sym == tmp
                file << "#{package.class.name.upcase} #{package.sha1} #{package.revision}\n"
                updated = true
              else
                file << "#{tag[0]} #{tag[1]} #{tag[2]}\n"
              end
            end
          end
          if not defined? updated
            file << "#{package.class.name.upcase} #{package.sha1} #{package.revision}\n"
          end
          # Write dependent packages tag.
          package.dependencies.each do |depend|
            depend_package = Package.instance depend
            file << "#{depend.upcase} #{depend_package.sha1} #{depend_package.revision}\n"
          end
        end
      end
    end
  end
end
