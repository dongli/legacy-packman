module PACKMAN
  class Fedora < RedHat
    type :Fedora
    check :version do
      `cat /etc/*-release`.match(/Fedora release (\d+)/)[1]
    end
  end
end
