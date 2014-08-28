class Openssl < PACKMAN::Package
  url 'https://www.openssl.org/source/openssl-1.0.1i.tar.gz'
  sha1 '74eed314fa2c93006df8d26cd9fc630a101abd76'
  version '1.0.1i'

  depends_on 'zlib'

  if PACKMAN::OS.distro == :Ubuntu
    # Ubuntu add version information into Openssl so that other tools will
    # complain about the missing version information if PACKMAN install
    # Openssl
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
    begin
      case PACKMAN::OS.distro
      when :Ubuntu
        PACKMAN.slim_run 'dpkg-query -l libssl-dev'
      end
    rescue
      return false
    end
  end

  def install_method
    case PACKMAN::OS.distro
    when :Ubuntu
      return "sudo apt-get install libssl-dev"
    end
  end
end
