class Readline_ < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/readline/readline-6.3.tar.gz'
  sha1 '017b92dc7fd4e636a2b5c9265a77ccc05798c9e1'
  version '6.3'

  depends_on :ncurses

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-multibyte
    ]
    args << '--with-curses' if PACKMAN.mac?
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
