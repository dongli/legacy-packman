class Readline < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/readline/readline-6.3.tar.gz'
  sha1 '017b92dc7fd4e636a2b5c9265a77ccc05798c9e1'
  version '6.3'

  depends_on 'ncurses'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --enable-multibyte
    ]
    if PACKMAN::OS.distro != :Mac_OS_X
      args << '--with-curses'
      PACKMAN.append_env "CFLAGS='-I#{PACKMAN.prefix Ncurses}/include'"
      PACKMAN.append_env "LDFLAGS='-L#{PACKMAN.prefix Ncurses}/lib'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end

  def installed?
    if PACKMAN::OS.mac_gang?
      return File.exist? '/usr/include/readline/readline.h'
    end
  end
end
