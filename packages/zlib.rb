class Zlib < PACKMAN::Package
  url 'http://zlib.net/zlib-1.2.8.tar.gz'
  sha1 'a4d316c404ff54ca545ea71a27af7dbc29817088'
  version '1.2.8'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end