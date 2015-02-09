module PACKMAN
  class FedoraSpec < RedHatSpec
    distro :Fedora
    version {
      `cat /etc/*-release`.match(/VERSION_ID=(\d+)/)[1]
    }
  end
end
