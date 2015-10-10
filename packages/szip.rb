class Szip < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz'
  sha1 'd241c9acc26426a831765d660b683b853b83c131'
  version '2.1'

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :gnu, '=~ 5.2' ]
    sha1 '1b13f84260feda69511bc8fa63abab08ebcf8ef6'
    version '2.1'
  end

  def install
    if PACKMAN.cygwin?
      PACKMAN.replace 'src/Makefile.am', {
        /libsz_la_LDFLAGS\s*=\s*(.*)$/ => 'libsz_la_LDFLAGS = \1 -no-undefined'
      }
      PACKMAN.replace 'src/Makefile.in', {
        /libsz_la_LDFLAGS\s*=\s*(.*)$/ => 'libsz_la_LDFLAGS = \1 -no-undefined'
      }
    end
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
