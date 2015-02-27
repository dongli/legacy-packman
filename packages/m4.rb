class M4 < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/m4/m4-1.4.17.tar.xz'
  sha1 '74ad71fa100ec8c13bc715082757eb9ab1e4bbb0'
  version '1.4.17'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
