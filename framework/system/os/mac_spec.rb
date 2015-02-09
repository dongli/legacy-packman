module PACKMAN
  class MacSpec < OsSpec
    vendor :Apple
    type :Darwin
    distro :Mac_OS_X
    version {
      `sw_vers | grep ProductVersion | cut -d ':' -f 2`
    }
    package_manager :Homebrew, {
      :query_command => 'brew list',
      :install_command => 'brew install'
    }
  end
end
