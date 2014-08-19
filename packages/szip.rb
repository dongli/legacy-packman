class Szip < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz'
  sha1 'd241c9acc26426a831765d660b683b853b83c131'
  version '2.1'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-debug
      --disable-dependency-tracking
    ]

    PACKMAN.run('./configure', *args)
    PACKMAN.run('make install')
  end
end
