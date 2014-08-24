class Mesa3d < PACKMAN::Package
  url 'ftp://ftp.freedesktop.org/pub/mesa/10.2.6/MesaLib-10.2.6.tar.gz'
  sha1 '6936a1d6dda6b89b36d61a12cd04e0d5364b75e4'
  version '10.2.6'

  depends_on 'glproto'
  depends_on 'libdrm'

  skip_on :Mac_OS_X

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end