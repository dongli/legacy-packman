$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "cli"
require "file/file_manager"
require "minitest/autorun"

describe PACKMAN do
  it 'should judge directory is empty or not' do
    PACKMAN.mkdir 'tmp', :silent
    PACKMAN.is_directory_empty?('tmp').must_equal true
    PACKMAN.rm 'tmp'
    PACKMAN.is_directory_empty?('.').must_equal false
  end
end