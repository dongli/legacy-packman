module PACKMAN
  class Cygwin < Os
    vendor :Cygwin
    type :Cygwin
    check :version do
      `uname`.match(/(\d+\.\d+)/)[1]
    end
    package_manager :CYGWIN, {
      :query_command => 'cygcheck -c'
    }
  end
end
