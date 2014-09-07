class Opendap < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/libdap-3.12.1.tar.gz'
  sha1 'bfb72dd3035e7720b1ada0bf762b9ab80bb6bbf2'
  version '3.12.1'

  depends_on 'curl'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-debug
      --disable-dependency-tracking
      --with-curl=#{PACKMAN::Package.prefix(Curl)}
      --with-included-regex
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end