class Autoconf < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz'
  sha1 '562471cbcb0dd0fa42a76665acf0dbb68479b78a'
  version '2.69'

  label 'should_be_provided_by_system'

  depends_on 'm4'

  def install
    ENV['PERL'] = '/usr/bin/perl'

    PACKMAN.run "./configure --prefix=#{prefix}"
    PACKMAN.run 'make install'
  end

  def installed?
    if PACKMAN.redhat?
      PACKMAN.os_installed? 'autoconf'
    elsif PACKMAN.mac?
      PACKMAN.does_command_exist? 'autom4te'
    end
  end

  def install_method
    if PACKMAN.redhat?
      PACKMAN.os_how_to_install 'autoconf'
    elsif PACKMAN.mac?

    end
  end
end
