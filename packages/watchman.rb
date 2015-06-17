class Watchman < PACKMAN::Package
  url 'https://github.com/facebook/watchman/archive/v3.2.0.tar.gz'
  sha1 'b7313c240e4977ee6ea8906bdca9680db34df2e9'
  version '3.2.0'
  filename 'watchman-3.2.0.tar.gz'

  label :compiler_insensitive

  depends_on 'pcre'

  def install
    PACKMAN.run './autogen.sh'
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-pcre=#{Pcre.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end