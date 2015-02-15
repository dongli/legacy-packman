class Libffi < PACKMAN::Package
  url 'http://mirrors.kernel.org/sources.redhat.com/libffi/libffi-3.0.13.tar.gz'
  sha1 'f5230890dc0be42fb5c58fbf793da253155de106'
  version '3.0.13'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
