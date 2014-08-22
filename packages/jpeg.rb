class Jpeg < PACKMAN::Package
  url 'http://www.ijg.org/files/jpegsr6b.zip'
  sha1 '713ebaf4a95484531351e4e5cc15cc889d38a697'
  version '6b'

  def install
    PACKMAN.replace('configure', /\r/, '')
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    # Silly Jpeg does not mkdir necessary install directories!
    PACKMAN.mkdir("#{PACKMAN::Package.prefix(self)}/bin", :force)
    PACKMAN.mkdir("#{PACKMAN::Package.prefix(self)}/man/man1", :force)
    PACKMAN.run 'make install'
  end
end