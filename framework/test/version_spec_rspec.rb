$LOAD_PATH << "#{ENV['PACKMAN_ROOT']}/framework"
require 'utils'
require 'version_spec'

describe PACKMAN::VersionSpec do
  it 'should be initialized successfully from valid version string.' do
    v = PACKMAN::VersionSpec.new '1'
    expect(v.major).to eq(1)
    expect(v.minor).to eq(nil)
    expect(v.revision).to eq(nil)
    expect(v.alpha).to eq(nil)
    expect(v.beta).to eq(nil)
    expect(v.release_candidate).to eq(nil)

    v = PACKMAN::VersionSpec.new '1.1'
    expect(v.major).to eq(1)
    expect(v.minor).to eq(1)
    expect(v.revision).to eq(nil)
    expect(v.alpha).to eq(nil)
    expect(v.beta).to eq(nil)
    expect(v.release_candidate).to eq(nil)

    v = PACKMAN::VersionSpec.new '2.0-a1'
    expect(v.major).to eq(2)
    expect(v.minor).to eq(0)
    expect(v.revision).to eq(nil)
    expect(v.alpha).to eq(1)
    expect(v.beta).to eq(nil)
    expect(v.release_candidate).to eq(nil)

    v = PACKMAN::VersionSpec.new '2.0b5'
    expect(v.major).to eq(2)
    expect(v.minor).to eq(0)
    expect(v.revision).to eq(nil)
    expect(v.alpha).to eq(nil)
    expect(v.beta).to eq(5)
    expect(v.release_candidate).to eq(nil)

    v = PACKMAN::VersionSpec.new '3.0rc5'
    expect(v.major).to eq(3)
    expect(v.minor).to eq(0)
    expect(v.revision).to eq(nil)
    expect(v.alpha).to eq(nil)
    expect(v.beta).to eq(nil)
    expect(v.release_candidate).to eq(5)

    v = PACKMAN::VersionSpec.new '3.0.1'
    expect(v.major).to eq(3)
    expect(v.minor).to eq(0)
    expect(v.revision).to eq(1)
    expect(v.alpha).to eq(nil)
    expect(v.beta).to eq(nil)
    expect(v.release_candidate).to eq(nil)
  end

  it 'should not be initialized successfully from invalid version string.' do
    expect {
      begin
        PACKMAN::VersionSpec.new '3.0.1.1'
      rescue SystemExit
      end
    }.to output(/Bad version identifer/).to_stdout

    expect {
      begin
        PACKMAN::VersionSpec.new '3.0rc'
      rescue SystemExit
      end
    }.to output(/Bad version identifer/).to_stdout
  end

  it 'should judge two VersionSpec objects successfully.' do
    v1 = PACKMAN::VersionSpec.new '1.0'
    v2 = PACKMAN::VersionSpec.new '2.1'
    expect(v2 >= v1).to eq(true)

    v1 = PACKMAN::VersionSpec.new '1.0.4'
    v2 = PACKMAN::VersionSpec.new '2.1.0'
    expect(v2 >= v1).to eq(true)

    v1 = PACKMAN::VersionSpec.new '1.0'
    v2 = PACKMAN::VersionSpec.new '1.0rc2'
    expect(v2 >= v1).to eq(true)

    v1 = PACKMAN::VersionSpec.new '2.0'
    v2 = PACKMAN::VersionSpec.new '1.0rc2'
    expect(v2 >= v1).to eq(false)

    v1 = PACKMAN::VersionSpec.new '2.0a5'
    v2 = PACKMAN::VersionSpec.new '2.0rc2'
    expect(v2 >= v1).to eq(true)

    v1 = PACKMAN::VersionSpec.new '2.0rc5'
    v2 = PACKMAN::VersionSpec.new '3.0rc2'
    expect(v2 >= v1).to eq(true)

    v1 = PACKMAN::VersionSpec.new '2.0rc5'
    v2 = PACKMAN::VersionSpec.new '2.0rc5'
    expect(v2 == v1).to eq(true)

    v1 = PACKMAN::VersionSpec.new '2.0rc5'
    v2 = PACKMAN::VersionSpec.new '2.0rc6'
    expect(v2 == v1).to eq(false)

    v1 = PACKMAN::VersionSpec.new '10.9'
    v2 = PACKMAN::VersionSpec.new '10.9.4'
    expect(v2 == v1).to eq(false)

    v1 = PACKMAN::VersionSpec.new '2.0'
    v2 = PACKMAN::VersionSpec.new '2.0rc6'
    expect(v1 =~ v2).to eq(true)

    v1 = PACKMAN::VersionSpec.new '2.0rc6'
    v2 = PACKMAN::VersionSpec.new '2.0'
    expect(v1 =~ v2).to eq(false)

    v1 = PACKMAN::VersionSpec.new '2.0rc5'
    v2 = PACKMAN::VersionSpec.new '2.0rc6'
    expect(v1 =~ v2).to eq(false)

    v1 = PACKMAN::VersionSpec.new '2.0rc5'
    v2 = PACKMAN::VersionSpec.new '2.0a6'
    expect(v1 =~ v2).to eq(false)

    v1 = PACKMAN::VersionSpec.new '10.9'
    v2 = PACKMAN::VersionSpec.new '10.9.4'
    expect(v1 =~ v2).to eq(true)

    v1 = PACKMAN::VersionSpec.new '10.9.4'
    v2 = PACKMAN::VersionSpec.new '10.9'
    expect(v1 =~ v2).to eq(false)
  end

  it 'should judge bad comparison.' do
    expect {
      begin
        v = PACKMAN::VersionSpec.new '1.0'
        v >= 'abc'
      rescue SystemExit
      end
    }.to output(/Invalid argument/).to_stdout

    expect {
      begin
        v = PACKMAN::VersionSpec.new '1.0'
        v == 'abc'
      rescue SystemExit
      end
    }.to output(/Invalid argument/).to_stdout
  end

  it 'should convert to string.' do
    v = PACKMAN::VersionSpec.new '3.0.1'
    expect(v.to_s).to eq('3.0.1')
  end
end
