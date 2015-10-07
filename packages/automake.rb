class Automake < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/automake/automake-1.15.tar.gz'
  sha1 'b5a840c7ec4321e78fdc9472e476263fa6614ca1'
  version '1.15'

  label :try_system_package_first
  label :compiler_insensitive

  depends_on :autoconf

  def install
    ENV['PERL'] = '/usr/bin/perl'

    PACKMAN.run "./configure --prefix=#{prefix}"
    PACKMAN.run 'make install'
  end

  def installed?
    if PACKMAN.redhat? or PACKMAN.debian?
      PACKMAN.os_installed? 'automake'
    elsif PACKMAN.mac?
      PACKMAN.does_command_exist? 'autom4te'
    end
  end
end
