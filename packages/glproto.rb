class Glproto < PACKMAN::Package
  # http://cgit.freedesktop.org/xorg/proto/glproto/
  git 'http://anongit.freedesktop.org/git/xorg/proto/glproto.git'
  tag 'glproto-1.4.17'
  dirname 'glproto-1.4.17'
  sha1 '1c0c8626acd52bced930f08bc0c346d3519cf7db'
  version '1.4.17'

  depends_on 'xorg_macros'

  skip_on :Mac_OS_X

  def install
    PACKMAN.replace 'autogen.sh', {
      /^(autoreconf) (-v --install \|\| exit 1)/ => "\\1 -I#{PACKMAN::Package.prefix(Xorg_macros)}/share/aclocal \\2"
    }
    PACKMAN.run './autogen.sh'
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end