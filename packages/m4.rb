class M4 < PACKMAN::Package
  url 'http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz'
  sha1 '4f80aed6d8ae3dacf97a0cb6e989845269e342f0'
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
