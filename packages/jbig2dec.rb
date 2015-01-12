class Jbig2dec < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/jbig2dec/jbig2dec/0.11/jbig2dec-0.11.tar.gz'
  sha1 '349cd765616db7aac1f4dd1d45957d1da65ea925'
  version '0.11'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end