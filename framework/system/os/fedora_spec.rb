module PACKMAN
  class FedoraSpec < RedHatSpec
    distro :Fedora
    check :version do
      `cat /etc/*-release`.match(/VERSION_ID=(\d+)/)[1]
    end
  end
end
