require "utils"
require "cli"
require "version_spec"
require "command_line"
require "config_manager"
require "os"
require "package_spec"
require "package"
require "autotool_helper"
require "cmake_helper"
require "compiler_helper"
require "gcc_compiler_helper"
require "intel_compiler_helper"
require "llvm_compiler_helper"
require "run_manager"
require "edit_config_file"
require "collect_packages"
require "install_packages"
require "switch_packages"
require "mirror_packages"

PACKMAN::OS.init
PACKMAN::CommandLine.init
PACKMAN::ConfigManager.init
PACKMAN::CompilerHelper.init

Kernel.trap('INT') do
  print "GOOD BYE!\n"
  exit
end
