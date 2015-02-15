class Udunits < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.1.24.tar.gz'
  sha1 '64bbb4b852146fb5d476baf4d37c9d673cfa42f9'
  version '2.1.24'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
