module PACKMAN
  class Commands
    def self.edit
      CommandLine.packages.each do |package_name|
        editor = 'vim'
        system "#{editor} #{ENV['PACKMAN_ROOT']}/packages/#{package_name.downcase}.rb"
      end
    end
  end
end
