class Boost < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/boost/boost/1.56.0/boost_1_56_0.tar.bz2'
  sha1 'f94bb008900ed5ba1994a1072140590784b9b5df'
  version '1.56.0'

  # Toolsets supported by Boost:
  #   acc, como, darwin, gcc, intel-darwin, intel-linux, kcc, kylix,
  #   mipspro, mingw(msys), pathscale, pgi, qcc, sun, sunpro, tru64cxx, vacpp

  option 'use_cxx11' => true

  def install
    cxx_compiler = PACKMAN.compiler_command 'c++'
    compiler_flags = PACKMAN.default_compiler_flags 'c++'
    toolset = PACKMAN.compiler_vendor 'c++'
    if toolset == 'intel'
      # Lower version (e.g. 11.1) has issues to compile Boost.
      helper = PACKMAN.compiler_helper 'intel'
      if ['11.1'].include? helper.version
        PACKMAN::CLI.report_error "Intel compiler is too old to compile Boost! See "+
          "https://software.intel.com/en-us/articles/boost-1400-compilation-error-while-building-with-intel-compiler/"
      end
      case PACKMAN::OS.type
      when :Darwin
        toolset << '-darwin'
      when :Linux
        toolset << '-linux'
      end
    elsif toolset == 'gnu'
      case PACKMAN::OS.type
      when :Darwin
        toolset = 'darwin-gcc'
      when :Linux
        toolset = 'linux-gcc'
      end
    elsif toolset == 'llvm'
      case PACKMAN::OS.type
      when :Darwin
        toolset = 'clang-darwin'
      when :Linux
        toolset = 'clang-linux'
      end
    end
    compiler_flags << ' -std=c++11' if use_cxx11?
    open('user-config.jam', 'w') do |file|
      file << "using #{toolset} : : #{cxx_compiler} : <compilerflags>#{compiler_flags}"
    end
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
    ]
    PACKMAN.run './bootstrap.sh', *args
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      -q
      -d2
      -j2
      toolset=#{toolset}
      variant=release
      install
    ]
    # Check if python development files are installed.
    if not PACKMAN::OS.installed? ['python-dev', 'python-devel']
      PACKMAN::CLI.report_warning 'Python development files are not installed, '+
        'so Boost will be installed without python library.'
      PACKMAN::CLI.report_warning "If you really need that library, cancel and "+
        "install #{PACKMAN::CLI.red 'python-dev'} or #{PACKMAN::CLI.red 'python-devel'}."
      args << '--without-python'
    end
    if PACKMAN::OS.mac_gang? and toolset =~ /clang/
      # Boost.Log cannot be built using Apple GCC at the moment. Disabled
      # on such systems.
      args << "--without-log"
    end
    PACKMAN.run './b2', *args
  end
end
