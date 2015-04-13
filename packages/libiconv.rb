class Libiconv < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/libiconv/libiconv-1.14.tar.gz'
  sha1 'be7d67e50d72ff067b2c0291311bc283add36965'
  version '1.14'

  skip_on :Mac_OS_X

  def system_prefix; '/usr'; end if PACKMAN.mac?

  def install
    PACKMAN.replace 'srclib/stdio.in.h', {
      /(_GL_WARN_ON_USE \(gets, "gets is a security hole - use fgets instead"\);)/ => "#if defined(__GLIBC__) && !defined(__UCLIBC__) && !__GLIBC_PREREQ(2, 16)\n\\1\n#endif\n"
    }
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --enable-extra-encodings
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end

  def installed?
    if PACKMAN.mac?
      File.exist? '/usr/lib/libiconv.dylib'
    end
  end
end
