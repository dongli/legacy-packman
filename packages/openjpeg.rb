class Openjpeg < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/openjpeg.mirror/2.1.0/openjpeg-2.1.0.tar.gz'
  sha1 'c2a255f6b51ca96dc85cd6e85c89d300018cb1cb'
  version '2.1.0'

  depends_on 'cmake'
  depends_on 'little_cms'
  depends_on 'libtiff'
  depends_on 'libpng'

  def install
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE="Release"
    ]
    PACKMAN.run 'cmake .', *args
    PACKMAN.run 'make install'
  end
end
