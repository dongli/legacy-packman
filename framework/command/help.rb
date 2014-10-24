module PACKMAN
  class Commands
    def self.help
      CommandLine.print_usage
      print "See #{CLI.bold 'https://github.com/dongli/packman/wiki/Basic-Usages'} for more details.\n"
    end
  end
end
