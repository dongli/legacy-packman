class Libuv < PACKMAN::Package
  url 'https://github.com/libuv/libuv/archive/v1.7.5.tar.gz'
  sha1 'c435788d3fba280dfb07173b02e06cb666249e34'
  version '1.7.5'
  filename 'libuv-1.7.5.tar.gz'

  depends_on 'pkgconfig'
  depends_on 'automake'
  depends_on 'autoconf'
  depends_on 'libtool'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
    ]
    PACKMAN.run './autogen.sh'
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end
