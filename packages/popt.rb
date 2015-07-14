class Popt < PACKMAN::Package
  url 'http://rpm5.org/files/popt/popt-1.16.tar.gz'
  sha1 'cfe94a15a2404db85858a81ff8de27c8ff3e235e'
  version '1.16'

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