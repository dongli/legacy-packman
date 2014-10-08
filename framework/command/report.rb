module PACKMAN
  class Commands
    def self.report
      if not File.exist? "#{ENV['PACKMAN_ROOT']}/.version"
        CLI.report_error "Version is missing!"
      end
      current_version = File.open("#{ENV['PACKMAN_ROOT']}/.version", 'r').read.strip
      print "#{CLI.green 'packman'} #{CLI.bold current_version} "
      print "(Report BUG or ADVICE to #{CLI.bold 'https://github.com/dongli/packman/issues'})\n"
    end
  end
end
