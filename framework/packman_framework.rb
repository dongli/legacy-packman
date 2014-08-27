require "utils"
require "config_manager"
require "os"
require "package"
require "autotool_helper"
require "cmake_helper"
require "compiler_helper"
require "gcc_compiler_helper"
require "intel_compiler_helper"
require "run_manager"
require "collect_packages"
require "install_packages"
require "switch_packages"

PACKMAN::OS.init
PACKMAN::ConfigManager.init
PACKMAN::CompilerHelper.init
