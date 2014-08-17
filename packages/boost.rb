class Boost < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/boost/boost/1.56.0/boost_1_56_0.tar.bz2'
  sha1 'cef9a0cc7084b1d639e06cd3bc34e4251524c840'
  version '1.56.0'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      toolset=#{PACKMAN.get_cxx_vendor}-#{PACKMAN.get_cxx_version}
    ]
    PACKMAN.run './bootstrap.sh'
    PACKMAN.append 'project-config.jam', "using #{PACKMAN.get_cxx_vendor} : #{PACKMAN.get_cxx_version} : #{PACKMAN.get_cxx_compiler} : ;"
    PACKMAN.run './b2', *args
  end
end
