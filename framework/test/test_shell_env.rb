$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "system/shell/env"
require "uri"
require "minitest/autorun"

PACKMAN::Shell::Env.init

describe PACKMAN::Shell::Env do
  it 'should append and prepend environment variable, and clear successfully' do
    PACKMAN::Shell::Env.append 'FOO', 'BAR'
    PACKMAN::Shell::Env['FOO'].must_equal 'BAR'
    PACKMAN::Shell::Env.prepend 'FOO', 'COOL'
    PACKMAN::Shell::Env['FOO'].must_equal 'COOL BAR'
    PACKMAN::Shell::Env.append 'FOO', 'FOOD'
    PACKMAN::Shell::Env['FOO'].must_equal 'COOL BAR FOOD'
    PACKMAN::Shell::Env.append 'FOO', 'DOG', ':'
    PACKMAN::Shell::Env['FOO'].must_equal 'COOL BAR FOOD:DOG'
    PACKMAN::Shell::Env.clear
    PACKMAN::Shell::Env['FOO'].must_equal nil
  end

  it 'should preserve the order of environment variables as they are appended' do
    PACKMAN::Shell::Env.append 'C', '1'
    PACKMAN::Shell::Env.append 'A', '2'
    PACKMAN::Shell::Env.append 'B', '3'
    PACKMAN::Shell::Env.keys.must_equal ['C', 'A', 'B']
  end
end