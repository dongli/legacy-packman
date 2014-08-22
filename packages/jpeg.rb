class Jpeg < PACKMAN::Package
  url 'http://www.ijg.org/files/jpegsrc.v6b.tar.gz'
  sha1 '7079f0d6c42fad0cfba382cf6ad322add1ace8f9'
  version '6b'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    # Silly Jpeg does not mkdir necessary install directories!
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/bin", :force
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/include", :force
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/lib", :force
    PACKMAN.mkdir "#{PACKMAN::Package.prefix(self)}/man/man1", :force
    PACKMAN.run 'make install'
    PACKMAN.run 'make install-lib'
    PACKMAN.run 'make install-headers'

    create_cmake_config 'JPEG', 'include', 'lib/libjpeg.a'
  end
end