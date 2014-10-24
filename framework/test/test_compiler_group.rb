$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "compiler/compiler_group_spec"
require "compiler/compiler_group"
require "compiler/gcc_compiler_group"
require "compiler/intel_compiler_group"
require "minitest/autorun"

describe PACKMAN::GccCompilerGroup do
  it 'should be initialized successfully.' do
    gcc = PACKMAN::GccCompilerGroup.new
    gcc.vendor.must_equal 'gnu'
    gcc.compiler_commands.has_key?('c').must_equal true
    gcc.compiler_commands['c'].must_equal 'gcc'
    gcc.compiler_commands.has_key?('c++').must_equal true
    gcc.compiler_commands['c++'].must_equal 'g++'
    gcc.compiler_commands.has_key?('fortran').must_equal true
    gcc.compiler_commands['fortran'].must_equal 'gfortran'
  end
end
