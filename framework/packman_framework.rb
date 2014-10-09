require "utils"
require "cli"
require "version_spec"
require "command_line"
require "config_manager"
require "os"
require "autotool_helper"
require "cmake_helper"
require "run_manager"
require "compiler/compiler_group_spec"
require "compiler/compiler_group"
require "compiler/gcc_compiler_group"
require "compiler/intel_compiler_group"
require "compiler/llvm_compiler_group"
require "compiler/compiler_manager"
require "command/config"
require "command/collect"
require "command/install"
require "command/remove"
require "command/switch"
require "command/mirror"
require "command/update"
require "command/report"
require "command/help"
require "package/package_spec"
require "package/package"
require "package/package_loader"

require "pty"
require "expect"

PACKMAN::OS.init
PACKMAN::CommandLine.init
PACKMAN::ConfigManager.init
PACKMAN::CompilerManager.init

begin
  PACKMAN::ConfigManager.parse
rescue SyntaxError => e
  if not PACKMAN::CommandLine.subcommand == :config
    PACKMAN::CLI.report_error "Failed to parse #{PACKMAN::CLI.red PACKMAN::CommandLine.config_file}!\n#{e}"
  end
end

if not PACKMAN::CommandLine.subcommand == :config
  PACKMAN::PackageLoader.init
end

Kernel.trap('INT') do
  print "GOOD BYE!\n"
  exit
end
