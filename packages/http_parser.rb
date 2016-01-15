class Http_parser < PACKMAN::Package
  url 'https://github.com/nodejs/http-parser/archive/v2.6.0.tar.gz'
  sha1 '82938a3db03de57626768a85d195fc61039bf6f5'
  version '2.6.0'
  filename 'http_parser-2.6.0.tar.gz'

  def install
    PACKMAN.run "make install PREFIX=#{prefix}"
  end
end
