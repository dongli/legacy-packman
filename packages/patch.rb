class Patch < PACKMAN::Package
  url 'http://ftp.gnu.org/gnu/patch/patch-2.7.5.tar.gz'
  sha1 '04d23f6e48e95efb07d12ccf44d1f35fb210f457'
  version '2.7.5'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
