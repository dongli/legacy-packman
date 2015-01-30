class Bison < PACKMAN::Package
  url 'http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.xz'
  sha1 '8270497aad88c7dd4f2c317298c50513fb0c3c8e'
  version '3.0.4'

  label 'compiler_insensitive'

  depends_on 'libiconv'
  depends_on 'gettext'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --with-libiconv-prefix=#{PACKMAN.prefix Libiconv}
      --with-libintl-prefix=#{PACKMAN.prefix Gettext}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end