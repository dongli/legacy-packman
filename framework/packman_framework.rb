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
require "run_manager"
require "compiler/compiler_group_spec"
require "compiler/compiler_group"
require "compiler/gcc_compiler_group"
require "compiler/intel_compiler_group"
require "compiler/llvm_compiler_group"
require "compiler/compiler_manager"
require "command/edit_config_file"
require "command/collect_packages"
require "command/install_packages"
require 'command/remove_packages'
require "command/switch_packages"
require "command/mirror_packages"

require "pty"
require "expect"

PACKMAN::OS.init
PACKMAN::CommandLine.init
PACKMAN::ConfigManager.init
PACKMAN::ConfigManager.parse
PACKMAN::CompilerManager.init

Kernel.trap('INT') do
  print "GOOD BYE!\n"
  exit
end
