class Openssl < PACKMAN::Package
  url 'https://www.openssl.org/source/openssl-1.0.1i.tar.gz'
  sha1 '74eed314fa2c93006df8d26cd9fc630a101abd76'
  version '1.0.1i'

  depends_on 'zlib'

  # Ubuntu add version information into Openssl so that other tools will
  # complain about the missing version information if PACKMAN install
  # Openssl
  if not PACKMAN::OS.cygwin_gang?
    label 'should_provided_by_system'
  end

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      zlib-dynamic
      shared
      enable-cms
    ]
    PACKMAN.run './config', *args
    PACKMAN.replace 'Makefile', {
      /^ZLIB_INCLUDE=\s*$/ => "ZLIB_INCLUDE=-I#{PACKMAN::Package.prefix(Zlib)}/include",
      /^LIBZLIB=\s*$/ => "LIBZLIB=-L#{PACKMAN::Package.prefix(Zlib)}/lib"
    }
    PACKMAN.run 'make'
    PACKMAN.run 'make test'
    PACKMAN.run 'make install'
  end

  def installed?
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.installed? ['libssl-dev']
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.installed? ['openssl', 'openssl-devel']
    elsif PACKMAN::OS.mac_gang?
      return true
    elsif PACKMAN::OS.cygwin_gang?
      return PACKMAN::OS.installed? ['libopenssl100', 'cygwin64-openssl']
    end
  end

  def install_method
    if PACKMAN::OS.debian_gang?
      return PACKMAN::OS.how_to_install ['libssl-dev']
    elsif PACKMAN::OS.redhat_gang?
      return PACKMAN::OS.how_to_install ['openssl', 'openssl-devel']
    elsif PACKMAN::OS.mac_gang?
      return true
    elsif PACKMAN::OS.cygwin_gang?
      return PACKMAN::OS.how_to_install ['libopenssl100', 'cygwin64-openssl']
    end
  end
end
