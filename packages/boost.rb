class Boost < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/boost/boost/1.56.0/boost_1_56_0.tar.bz2'
  sha1 'f94bb008900ed5ba1994a1072140590784b9b5df'
  version '1.56.0'

  # Toolsets supported by Boost:
  #   acc, como, darwin, gcc, intel-darwin, intel-linux, kcc, kylix,
  #   mipspro, mingw(msys), pathscale, pgi, qcc, sun, sunpro, tru64cxx, vacpp

  def install
    cxx_compiler = PACKMAN.compiler_command 'c++'
    default_flags = PACKMAN.default_flags 'c++', cxx_compiler
    toolset = PACKMAN.compiler_vendor 'c++', cxx_compiler
    if toolset == 'intel'
      # Lower version (e.g. 11.1) has issues to compile Boost.
      helper = PACKMAN.compiler_helper 'intel'
      if ['11.1'].include? helper.version
        PACKMAN.report_error "Intel compiler is too old to compile Boost! See "+
          "https://software.intel.com/en-us/articles/boost-1400-compilation-error-while-building-with-intel-compiler/"
      end
      case PACKMAN::OS.type
      when :Darwin
        toolset << '-darwin'
      when :Linux
        toolset << '-linux'
      end
    end
    open('user-config.jam', 'w') do |file|
      file << "using #{toolset} : : #{cxx_compiler} : <compilerflags>#{default_flags}"
    end
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run './bootstrap.sh', *args
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      -q
      -d2
      -j2
      toolset=#{toolset}
      variant=release
      install
    ]
    # Check if python development files are installed.
    if not PACKMAN::OS.check_system_package ['python-dev', 'python-devel']
      PACKMAN.report_warning 'Python development files are not installed, '+
        'so Boost will be installed without python library.'
      PACKMAN.report_warning "If you really need that library, cancel and "+
        "install #{PACKMAN::Tty.red}python-dev#{PACKMAN::Tty.reset} or "+
        "#{PACKMAN::Tty.red}python-devel#{PACKMAN::Tty.reset}."
      args << '--without-python'      
    end
    PACKMAN.run './b2', *args
  end
end
