$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require "command_line"
require "cli"
require "version_spec"
require "minitest/autorun"

describe PACKMAN::VersionSpec do
  it 'should be initialized successfully from valid version string.' do
    v = PACKMAN::VersionSpec.new '1'
    v.major.must_equal 1
    v.minor.must_equal nil
    v.revision.must_equal nil
    v.alpha.must_equal nil
    v.beta.must_equal nil
    v.release_candidate.must_equal nil

    v = PACKMAN::VersionSpec.new '1.1'
    v.major.must_equal 1
    v.minor.must_equal 1
    v.revision.must_equal nil
    v.alpha.must_equal nil
    v.beta.must_equal nil
    v.release_candidate.must_equal nil

    v = PACKMAN::VersionSpec.new '2.0-a1'
    v.major.must_equal 2
    v.minor.must_equal 0
    v.revision.must_equal nil
    v.alpha.must_equal 1
    v.beta.must_equal nil
    v.release_candidate.must_equal nil

    v = PACKMAN::VersionSpec.new '2.0b5'
    v.major.must_equal 2
    v.minor.must_equal 0
    v.revision.must_equal nil
    v.alpha.must_equal nil
    v.beta.must_equal 5
    v.release_candidate.must_equal nil

    v = PACKMAN::VersionSpec.new '3.0rc5'
    v.major.must_equal 3
    v.minor.must_equal 0
    v.revision.must_equal nil
    v.alpha.must_equal nil
    v.beta.must_equal nil
    v.release_candidate.must_equal 5

    v = PACKMAN::VersionSpec.new '3.0.1'
    v.major.must_equal 3
    v.minor.must_equal 0
    v.revision.must_equal 1
    v.alpha.must_equal nil
    v.beta.must_equal nil
    v.release_candidate.must_equal nil
  end

  it 'should not be initialized from invalid version string.' do
    proc {
      begin
        PACKMAN::VersionSpec.new '3.0.1.1'
      rescue SystemExit
      end
    }.must_output /Bad version identifer/

    proc {
      begin
        PACKMAN::VersionSpec.new '3.0rc'
      rescue SystemExit
      end
    }.must_output /Bad version identifer/

    proc {
      begin
        PACKMAN::VersionSpec.new 'a.b.c'
      rescue SystemExit
      end
    }.must_output /Bad version identifer/
  end

  it 'should judge two VersionSpec objects successfully.' do
    [ ['2.1'   , '1.0'   ],
      ['2.1.0' , '1.0.4' ],
      ['1.0rc2', '1.0'   ],
      ['2.0rc2', '2.0a5' ],
      ['3.0rc2', '2.0rc5']
    ].each do |test|
      v1 = PACKMAN::VersionSpec.new test.first
      v2 = PACKMAN::VersionSpec.new test.last
      (v1 >= v2).must_equal true
    end

    [ ['1.0rc2', '2.0'] ].each do |test|
      v1 = PACKMAN::VersionSpec.new test.first
      v2 = PACKMAN::VersionSpec.new test.last
      (v1 >= v2).must_equal false
    end

    [ ['2.0rc5', '2.0rc5'] ].each do |test|
      v1 = PACKMAN::VersionSpec.new test.first
      v2 = PACKMAN::VersionSpec.new test.last
      (v1 == v2).must_equal true
    end

    [ ['2.0rc5', '2.0rc6'],
      ['10.9',   '10.9.4']
    ].each do |test|
      v1 = PACKMAN::VersionSpec.new test.first
      v2 = PACKMAN::VersionSpec.new test.last
      (v1 == v2).must_equal false
    end

    [ ['2.0rc6', '2.0'],
      ['10.9.4', '10.9']
    ].each do |test|
      v1 = PACKMAN::VersionSpec.new test.first
      v2 = PACKMAN::VersionSpec.new test.last
      (v1 =~ v2).must_equal true
    end

    [ ['2.0',    '2.0rc6'],
      ['2.0rc5', '2.0rc6'],
      ['2.0rc5', '2.0a6' ],
      ['10.9',   '10.9.4']
    ].each do |test|
      v1 = PACKMAN::VersionSpec.new test.first
      v2 = PACKMAN::VersionSpec.new test.last
      (v1 =~ v2).must_equal false
    end

    [ ['2.1'   , '1.0'   ],
      ['2.1.0' , '1.0.4' ],
      ['1.0rc2', '1.0'   ],
      ['2.0rc2', '2.0a5' ],
      ['3.0rc2', '2.0rc5']
    ].each do |test|
      v = PACKMAN::VersionSpec.new test.first
      (v >= test.last).must_equal true
    end

    [ ['1.0rc2', '2.0'] ].each do |test|
      v = PACKMAN::VersionSpec.new test.first
      (v >= test.last).must_equal false
    end

    [ ['2.0rc5', '2.0rc5'] ].each do |test|
      v = PACKMAN::VersionSpec.new test.first
      (v == test.last).must_equal true
    end

    [ ['2.0rc5', '2.0rc6'],
      ['10.9',   '10.9.4']
    ].each do |test|
      v = PACKMAN::VersionSpec.new test.first
      (v == test.last).must_equal false
    end

    [ ['2.0rc6', '2.0'],
      ['10.9.4', '10.9']
    ].each do |test|
      v = PACKMAN::VersionSpec.new test.first
      (v =~ test.last).must_equal true
    end

    [ ['2.0',    '2.0rc6'],
      ['2.0rc5', '2.0rc6'],
      ['2.0rc5', '2.0a6' ],
      ['10.9',   '10.9.4']
    ].each do |test|
      v = PACKMAN::VersionSpec.new test.first
      (v =~ test.last).must_equal false
    end
  end

  it 'should judge bad comparison.' do
    [ 1, nil ].each do |test|
        proc {
          begin
            v = PACKMAN::VersionSpec.new '1.0'
            v >= test
          rescue SystemExit
          end
        }.must_output /Invalid argument/
    end

    proc {
      begin
        v = PACKMAN::VersionSpec.new '1.0'
        v == 'a.b.c'
      rescue SystemExit
      end
    }.must_output /Bad version identifer/
  end

  it 'should convert to string.' do
    v = PACKMAN::VersionSpec.new '3.0.1'
    v.to_s.must_equal '3.0.1'
  end
end
