class Tar < PACKMAN::Package
  url 'ftp://ftp.gnu.org/gnu/tar/tar-1.28.tar.gz'
  sha1 'cd30a13bbfefb54b17e039be7c43d2592dd3d5d0'
  version '1.28'

  label :compiler_insensitive

  depends_on 'xz'
  depends_on 'bzip2'
  depends_on 'libiconv'
  depends_on 'intltool'

  if PACKMAN.mac?
    patch do
      url "https://gist.githubusercontent.com/mistydemeo/10fbae8b8441359ba86d/raw/e5c183b72036821856f9e82b46fba6185e10e8b9/gnutar-configure-xattrs.patch"
      sha1 "55d570de077eb1dd30b1e499484f28636fbda882"
    end
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --enable-dependency-tracking
      --with-xz=#{Xz.bin}/xz
      --with-bzip2=#{Bzip2.bin}/bzip2
      --with-libiconv-prefix=#{Libiconv.prefix}
      --with-libintl-prefix=#{Intltool.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end