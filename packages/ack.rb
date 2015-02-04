class Ack < PACKMAN::Package
  url 'http://beyondgrep.com/ack-2.14-single-file'
  sha1 '49c43603420521e18659ce3c50778a4894dd4a5f'
  version '2.14'

  label 'compiler_insensitive'

  def install
    PACKMAN.mkdir PACKMAN.prefix(self), :force
    PACKMAN.mkdir "#{PACKMAN.prefix self}/bin", :force
    PACKMAN.mkdir "#{PACKMAN.prefix self}/share/man/man1", :force
    PACKMAN.cp "ack-#{version}-single-file", "#{PACKMAN.prefix self}/bin/ack"
    PACKMAN.mkexe "#{PACKMAN.prefix self}/bin/ack"
    PACKMAN.run "pod2man #{PACKMAN.prefix self}/bin/ack #{PACKMAN.prefix self}/share/man/man1/ack.1"
  end
end