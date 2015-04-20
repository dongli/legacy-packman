module PACKMAN
  class Mac < Os
    vendor :Apple
    type :Mac_OS_X
    check :version do
      `sw_vers | grep ProductVersion | cut -d ':' -f 2`
    end
    package_manager :Homebrew, {
      :query_command => 'brew list',
      :install_command => 'brew install'
    }
    check :Xcode do
      PACKMAN.does_command_exist? 'xcode-select'
    end
    check :CommandLineTools do
      if version >= '10.9'
        `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>&1`
      elsif version >= '10.8'
        `pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI 2>&1`
      end
      $?.success?
    end
  end
end
