$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "package/package_spec"
require "cli"
require "uri"
require "command_line"
require "minitest/autorun"

# PACKMAN::CommandLine.options['-debug'] = nil

describe PACKMAN::PackageSpec do
  it 'should initialize expectly' do
    p = PACKMAN::PackageSpec.new
    p.options.has_key?('skip_test').must_equal true
    p.options['skip_test'].must_equal false
    p.option_valid_types['skip_test'].must_equal :boolean
    p.options.has_key?('compiler_set_indices').must_equal true
    p.options['compiler_set_indices'].must_equal []
    p.option_valid_types['compiler_set_indices'].must_equal :integer_array
    p.options.has_key?('use_binary').must_equal true
    p.options['use_binary'].must_equal false
    p.option_valid_types['use_binary'].must_equal :boolean
  end

  it 'should get filename from a url' do
    p = PACKMAN::PackageSpec.new
    p.url 'http://foo.com/bar.tar.gz'
    p.url.must_equal 'http://foo.com/bar.tar.gz'
    p.filename.must_equal 'bar.tar.gz'
  end

  it 'should provide default option value for different types' do
    PACKMAN::PackageSpec.default_option_value(:boolean).must_equal false
    PACKMAN::PackageSpec.default_option_value(:integer_array).must_equal []
    PACKMAN::PackageSpec.default_option_value(:package_name).must_equal nil
  end

  it 'should set option correctly' do
    p = PACKMAN::PackageSpec.new

    proc {
      begin
        p.option 'foo'
      rescue SystemExit
      end
    }.must_output /The valid type or default value for the package option foo is not provided/

    proc {
      begin
        p.option 'skip_test' => :boolean
      rescue SystemExit
      end
    }.must_output ''

    proc {
      begin
        p.option 'skip_test' => :integer_array
      rescue SystemExit
      end
    }.must_output /Package option .+ has already been added/

    p.option 'not_use_cxx11' => false
    p.options.has_key?('not_use_cxx11').must_equal true
    p.options['not_use_cxx11'].must_equal false
    p.option_valid_types['not_use_cxx11'].must_equal :boolean

    proc {
      p.option 'compiler_set_indices' => 0
    }.must_output /Package option .* has already been added/
    p.options['compiler_set_indices'].must_equal [0]
    p.option_valid_types['compiler_set_indices'].must_equal :integer_array

    p.option 'use_mpi' => :package_name
    p.options['use_mpi'].must_equal nil
    p.option_valid_types['use_mpi'].must_equal :package_name
  end
end