class Ncurses < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/ncurses/ncurses-6.0.tar.gz'
  sha1 'acd606135a5124905da770803c05f1f20dd3b21c'
  version '6.0'

  label :skipped if PACKMAN.mac?

  def system_prefix; '/usr'; end if PACKMAN.mac?

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
    ]
    args << '--without-ada' if PACKMAN.compiler(:c).vendor == :intel
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end

  def installed?
    if PACKMAN.mac?
      return File.exist? '/usr/include/ncurses.h'
    end
  end

  def install_method
    if PACKMAN.mac?
      return 'Sorry, Mac should come with Ncurses...'
    end
  end
end
