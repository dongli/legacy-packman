module PACKMAN
  class Ubuntu < Debian
    vendor :Canonoical
    type :Ubuntu
    check :version do
      `cat /etc/*-release`.match(/DISTRIB_RELEASE=(\d+\.\d+)/)[1]
    end
  end
end
