class Zlib_ < PACKMAN::Package
  url 'http://zlib.net/zlib-1.2.8.tar.gz'
  sha1 'a4d316c404ff54ca545ea71a27af7dbc29817088'
  version '1.2.8'

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :gnu, '=~ 5.2' ]
    sha1 '9dc48403041e69e3793d6c066ae0925381eb85e6'
    version '1.2.8'
  end

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
