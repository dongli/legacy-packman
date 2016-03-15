class Charm < PACKMAN::Package
  url 'http://charm.cs.illinois.edu/distrib/charm-6.7.0.tar.gz'
  sha1 '1cf6fa3f8a719080690d6f9b70c44eb91caa2a46'
  version '6.7.0'

  # Possible values are 'charm++', 'ampi', 'fem', 'tau'
  option :target => 'charm++'
  # Possible values are 'udp', 'mpi', 'pami', 'gni', 'verbs', 'sm'.
  option :comm_type => 'sm'

  def target
    @target ||= 'charm++'
  end

  def build_type
    if PACKMAN.linux?
      os = 'linux-x86_64'
    elsif PACKMAN.mac?
      os = 'darwin-x86_64'
    end
    case comm_type
    when 'udp'
      comm = 'netlrts'
    when 'mpi'
      comm = 'mpi'
    when 'pami'
      comm = 'pamilrts'
    when 'gni'
      comm = 'gni'
    when 'verbs'
      comm = 'verbs'
    when 'sm'
      comm = 'multicore'
    end
    "#{comm}-#{os}"
  end

  def install
    args = %W[#{target} #{build_type}]
    case PACKMAN.compiler(:cxx).vendor
    when :intel
      args << 'icc'
      args << 'ifort' if PACKMAN.has_compiler? :fortran, :not_exit
    when :pgi
      args << 'pgcc'
    end
    PACKMAN.run './build', *args
    PACKMAN.work_in build_type do
      Dir.glob('**/*').each do |file|
        if File.symlink? file
          realpath = Pathname.new(file).realpath
          PACKMAN.rm file
          PACKMAN.cp realpath, file
        end
      end
      PACKMAN.rm 'tmp'
    end
    PACKMAN.mkdir prefix
    PACKMAN.cp build_type + '/*', prefix
  end
end
