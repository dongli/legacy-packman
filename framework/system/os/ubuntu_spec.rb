module PACKMAN
  class UbuntuSpec < DebianSpec
    vendor :Canonoical
    distro :Ubuntu
    version {
      `cat /etc/*-release`.match(/DISTRIB_RELEASE=(\d+\.\d+)/)[1]
    }
  end
end
