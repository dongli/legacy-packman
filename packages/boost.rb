class Boost < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/boost/boost/1.56.0/boost_1_56_0.tar.bz2'
  sha1 'f94bb008900ed5ba1994a1072140590784b9b5df'
  version '1.56.0'

  def install
    if PACKMAN::OS.type == :Darwin
      open('user-config.jam', 'w') do |file|
        file.puts "using darwin : : #{PACKMAN.get_cxx_compiler} : ;"
      end
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
    ]
    PACKMAN.run './b2 install', *args
  end
end
