module PACKMAN
  class PackageLegacy
    def fix_gcc
      gcc = Package.instance :Gcc
      if Commands.is_package_installed? gcc, :silent
        begin
          PACKMAN.replace "#{PACKMAN.prefix gcc}/bashrc", {
            /export GCC_ROOT=.*$/ => '',
            /\$\{GCC_ROOT\}/ => "#{PACKMAN.prefix gcc}"
          }, :silent
          CLI.report_notice "Gcc bashrc file is fixed."
        rescue SystemExit
        end
      end
    end
  end
end
