module PACKMAN
  class CygwinSpec < OsSpec
    vendor :Cygwin
    type :Cygwin
    distro :Cygwin
    check :version do
      `uname`.match(/(\d+\.\d+)/)[1]
    end
    package_manager :CYGWIN, {
      :query_command => 'cygcheck -c'
    }
  end
end
