class Bison < PACKMAN::Package
  url 'http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.gz'
  sha1 '8270497aad88c7dd4f2c317298c50513fb0c3c8e'
  version '3.0.4'

  label :compiler_insensitive

  depends_on 'm4'
  depends_on 'libiconv'
  depends_on 'gettext'

  def install
    args = %W[
      --prefix=#{prefix}
      --with-libiconv-prefix=#{Libiconv.prefix}
      --with-libintl-prefix=#{Gettext.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
