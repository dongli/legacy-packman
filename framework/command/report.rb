module PACKMAN
  def self.report
    if not File.exist? "#{ENV['PACKMAN_ROOT']}/.version"
      CLI.report_error "Version is missing!"
    end
    current_version = File.open("#{ENV['PACKMAN_ROOT']}/.version", 'r').read.strip
    print "#{CLI.bold current_version}\n"
  end
end