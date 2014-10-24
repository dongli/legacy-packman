$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "uri"
require "package/package_spec"
require "package/package"
require "package/package_loader"
require "cli"
require "command_line"
require "minitest/autorun"

describe PACKMAN::Package do
  it 'should change dependencies if the relevant option is given' do
    PACKMAN::PackageLoader.load_package :Hdf5
    package = PACKMAN::Package.instance :Hdf5
    package.dependencies.must_equal [:Zlib, :Szip]
    PACKMAN::PackageLoader.load_package :Hdf5, 'use_mpi' => 'mpich'
    package = PACKMAN::Package.instance :Hdf5
    package.dependencies.must_equal [:Zlib, :Szip, :Mpich]
  end
end