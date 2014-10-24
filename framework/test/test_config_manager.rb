$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "uri"
require "fileutils"
require "cli"
require "utils"
require "command_line"
require "file/file_manager"
require "compiler/compiler_group_spec"
require "compiler/compiler_group"
require "compiler/gcc_compiler_group"
require "compiler/compiler_manager"
require "package/package_spec"
require "package/package"
require "config_manager"
require "legacy/config_manager_legacy"
require "minitest/autorun"

describe PACKMAN::ConfigManager do
  before do
    $VERBOSE = nil
    FileUtils.rm_rf 'tmp'
    PACKMAN::ConfigManager.init
    PACKMAN::CompilerManager.init
  end

  it 'should report error when a config file is invalid' do
    PACKMAN::ConfigManager.template 'tmp'
    ARGV = ['install', 'tmp']
    PACKMAN::CommandLine.init
    proc {
      begin
        PACKMAN::ConfigManager.parse
      rescue SystemExit
      end
    }.must_output /You haven.t modified package_root in tmp/
    PACKMAN.replace 'tmp', { /package_root = .*/ => 'package_root = "./package_root"' }
    proc {
      begin
        PACKMAN::ConfigManager.parse
      rescue SystemExit
      end
    }.must_output /You haven.t modified install_root in tmp/
    PACKMAN.replace 'tmp', { /install_root = .*/ => 'install_root = "./install_root"' }
    proc {
      begin
        PACKMAN::ConfigManager.parse
      rescue SystemExit
      end
    }.must_output /You haven.t modified c compiler in tmp/m
    PACKMAN.replace 'tmp', {
      /"c" => .*/ => '"c" => "gcc",',
      /"c\+\+" => .*/ => '"c++" => "g++",',
      /"fortran" => .*/ => '"fortran" => "gfortran"'
    }
    proc {
      PACKMAN::ConfigManager.parse
    }
    FileUtils.rm_rf './package_root'
    FileUtils.rm_rf './install_root'
  end

  it 'should write out config file' do
    PACKMAN::ConfigManager.defaults['compiler_set_index'] = 0
    PACKMAN::ConfigManager.write 'tmp'
    File.open('tmp', 'r').read.must_match /defaults = {\n  "compiler_set_index" => 0\n}/m

    PACKMAN::ConfigManager.package_options[:Hdf5] = { 'use_binary' => false }
    PACKMAN::ConfigManager.write 'tmp'
    File.open('tmp', 'r').read.must_match /package_hdf5 = {\n}/m

    PACKMAN::ConfigManager.package_options[:Hdf5] = { 'use_binary' => true }
    PACKMAN::ConfigManager.write 'tmp'
    File.open('tmp', 'r').read.must_match /package_hdf5 = {\n  "use_binary" => true\n}/m

    PACKMAN::ConfigManager.package_options[:Hdf5] = { 'compiler_set_indices' => [] }
    PACKMAN::ConfigManager.write 'tmp'
    File.open('tmp', 'r').read.must_match /package_hdf5 = {\n}/m

    PACKMAN::ConfigManager.package_options[:Hdf5] = { 'compiler_set_indices' => [0,1] }
    PACKMAN::ConfigManager.write 'tmp'
    File.open('tmp', 'r').read.must_match /package_hdf5 = {\n  "compiler_set_indices" => \[0, 1\]\n}/m
  end

  after do
    FileUtils.rm_rf 'tmp'
  end
end