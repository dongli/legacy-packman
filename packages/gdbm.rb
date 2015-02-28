class Gdbm < PACKMAN::Package
  url 'https://ftp.gnu.org/gnu/gdbm/gdbm-1.11.tar.gz'
  sha1 'ce433d0f192c21d41089458ca5c8294efe9806b4'
  version '1.11'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-libgdbm-compat
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end