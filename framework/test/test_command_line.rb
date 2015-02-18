$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "system/os/os"
require "version_spec"
require "package/package"
require "package/package_spec"
require "file/file_manager"
require "cli"
require "config_manager"
require "command_line"
require "uri"
require "minitest/autorun"

$VERBOSE = nil
PACKMAN::OS.init

describe PACKMAN::CommandLine do
  it 'should initialize "install netcdf_fortran" successfully' do
    ARGV = [ 'install', 'netcdf_fortran' ]
    PACKMAN::CommandLine.init
    PACKMAN::CommandLine.subcommand.must_equal :install
    PACKMAN::CommandLine.packages.size.must_equal 1
    PACKMAN::CommandLine.packages.first.must_equal :Netcdf_fortran
    PACKMAN::CommandLine.options.empty?.must_equal true
  end

  it 'should initialize "install netcdf_fortran -debug" successfully' do
    ARGV = [ 'install', 'netcdf_fortran', '-debug' ]
    PACKMAN::CommandLine.init
    PACKMAN::CommandLine.subcommand.must_equal :install
    PACKMAN::CommandLine.packages.size.must_equal 1
    PACKMAN::CommandLine.packages.first.must_equal :Netcdf_fortran
    PACKMAN::CommandLine.options.size.must_equal 1
    PACKMAN::CommandLine.has_option?('-debug').must_equal true
  end

  it 'should complain invalid option "-foo"' do
    ARGV = [ 'install', 'netcdf_fortran', '-foo' ]
    proc {
      begin
        PACKMAN::CommandLine.init
        PACKMAN::CommandLine.check_options
      rescue SystemExit
      end
    }.must_output /Invalid command option -foo!/
  end

  describe 'PACKMAN::CommandLine handle package options' do
    it 'should recognize package option "-skip_test"' do
      ARGV = [ 'install', 'netcdf_fortran', '-skip_test' ]
      PACKMAN::CommandLine.init
      PACKMAN::CommandLine.check_options
      PACKMAN::CommandLine.options.size.must_equal 1
      PACKMAN::CommandLine.has_option?('-skip_test').must_equal true
    end

    it 'should propagate direct option to package' do
      ARGV = [ 'install', 'netcdf_fortran', '-skip_test', '-use_mpi=mpich' ]
      PACKMAN::CommandLine.init
      PACKMAN::CommandLine.check_options
      package = PACKMAN::Package.instance :Netcdf_fortran
      PACKMAN::CommandLine.propagate_options_to package
      package.skip_test?.must_equal true
      package.mpi.must_equal 'mpich'
    end

    it 'should propagate indirect option to dependency package' do
      ARGV = ['install', 'cdo', '-use_mpi=mpich']
      PACKMAN::CommandLine.init
      PACKMAN::CommandLine.check_options
      package = PACKMAN::Package.instance :Netcdf_fortran
      PACKMAN::CommandLine.propagate_options_to package
      package.skip_test?.must_equal false
      package.mpi.must_equal 'mpich'
    end

    it 'should report invalid option usage' do
      ARGV = [ 'install', 'netcdf_fortran', '-skip_test=foo' ]
      PACKMAN::CommandLine.init
      PACKMAN::CommandLine.check_options
      package = PACKMAN::Package.instance :Netcdf_fortran
      proc {
        begin
          PACKMAN::CommandLine.propagate_options_to package
        rescue SystemExit
        end
      }.must_output /A boolean is needed for option skip_test or nothing at all!/

      ARGV = [ 'install', 'netcdf_fortran', '-use_mpi=foo' ]
      PACKMAN::CommandLine.init
      PACKMAN::CommandLine.check_options
      package = PACKMAN::Package.instance :Netcdf_fortran
      proc {
        begin
          PACKMAN::CommandLine.propagate_options_to package
        rescue SystemExit
        end
      }.must_output /A package name is needed for option use_mpi!/
    end
  end
end