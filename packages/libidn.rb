class Libidn < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/libidn/libidn-1.29.tar.gz'
  sha1 'e0959eec9a03fd8053379b0aeab447c546c05ab2'
  version '1.29'

  depends_on :pkgconfig

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-csharp
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end