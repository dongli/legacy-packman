class M4 < PACKMAN::Package
  url 'http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz'
  sha1 '4f80aed6d8ae3dacf97a0cb6e989845269e342f0'
  version '1.4.17'

  label :compiler_insensitive

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 '1ef6faa28e6f69e6d939cfcfd6154cf188a54683'
    version '1.4.17'
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    args << 'CFLAGS=-fgnu89-inline' if PACKMAN.os.type == :RHEL
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
