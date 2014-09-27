require "./compiler_group_spec"
require "./compiler_group"
require "./gcc_compiler_group"
require "./intel_compiler_group"
require "rspec"

describe PACKMAN::GccCompilerGroup do
  it 'should be initialized successfully.' do
    gcc = PACKMAN::GccCompilerGroup.new
    expect(gcc.vendor).to eq('gnu')
    expect(gcc.compiler_commands.has_key? 'c').to be_true
    expect(gcc.compiler_commands['c']).to eq('gcc')
    expect(gcc.compiler_commands.has_key? 'c++').to be_true
    expect(gcc.compiler_commands['c++']).to eq('g++')
    expect(gcc.compiler_commands.has_key? 'fortran').to be_true
    expect(gcc.compiler_commands['fortran']).to eq('gfortran')
  end
end
