module PACKMAN
  class Fedora < RedHat
    type :Fedora
    check :version do
      `cat /etc/*-release`.match(/VERSION_ID=(\d+)/)[1]
    end
  end
end
