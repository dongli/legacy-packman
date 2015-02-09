module PACKMAN
  class CygwinSpec < OsSpec
    vendor :Cygwin
    type :Cygwin
    distro :Cygwin
    version {
      `uname`.match(/(\d+\.\d+)/)[1]
    }
    package_manager :CYGWIN, {
      :query_command => 'cygcheck -c'
    }
  end
end
