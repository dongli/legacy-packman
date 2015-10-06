class Bison < PACKMAN::Package
  url 'http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.gz'
  sha1 'ec1f2706a7cfedda06d29dc394b03e092a1e1b74'
  version '3.0.4'

  label :compiler_insensitive

  depends_on :m4
  depends_on :libiconv
  depends_on :gettext

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
