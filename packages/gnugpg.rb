class Gnugpg < PACKMAN::Package
  url 'https://gnupg.org/ftp/gcrypt/gnupg/gnupg-1.4.20.tar.bz2'
  sha1 'cbc9d960e3d8488c32675019a79fbfbf8680387e'
  version '1.4.20'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-asm
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end
