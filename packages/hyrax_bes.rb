class Hyrax_bes < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/bes-3.13.1.tar.gz'
  sha1 '18ac1bc46d0f7d01411905d3ef7bc6575f1e8184'
  version '3.13.1'

  belongs_to 'hyrax'

  depends_on 'uuid'
  depends_on 'readline'
  depends_on 'libxml2'
  depends_on 'opendap'
  depends_on 'gdal' # TODO: How to solve gdal failure?

  def install
    # Add the lacked 'cstring' header for GCC.
    if PACKMAN.compiler_vendor('c++') == 'gnu'
      PACKMAN.replace './cmdln/CmdClient.cc', {
        /^\s*(#include <cstdlib>)\s*$/ => "\\1\n#include <cstring>"
      }
      PACKMAN.replace './standalone/StandAloneClient.cc', {
        /^\s*(#include <cstdlib>)\s*$/ => "\\1\n#include <cstring>"
      }
    end
    # Why set DAP_CFLAGS? Because 'pkg-config --cflags libdap' does not give the
    # include directory of Libxml2!
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      DAP_CFLAGS='#{`#{PACKMAN.prefix(Opendap)}/bin/dap-config --cflags`.strip}'
    ]
    if not PACKMAN::OS.mac_gang?
      args << "CPPFLAGS='-I#{PACKMAN.prefix(Uuid)}/include -I#{PACKMAN.prefix(Readline)}/include'"
      args << "LDFLAGS='-L#{PACKMAN.prefix(Ncurses)}/lib -L#{PACKMAN.prefix(Readline)}/lib'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
    PACKMAN.caveat <<-EOT.gsub(/^\s+/, '')
      Set "BES.Catalog.catalog.RootDirectory" in #{PACKMAN.prefix(self)}/etc/bes/bes.conf to the directory where your data reside.
    EOT
  end

  def postfix
    # Change user name and group name in bes.conf
    user_name = ENV['USER']
    if PACKMAN::OS.mac_gang?
      group_name = 'staff'
    else
      group_name = user_name
    end
    PACKMAN.replace "#{PACKMAN.prefix(self)}/etc/bes/bes.conf", {
      'BES.User=user_name' => "BES.User=#{user_name}",
      'BES.Group=group_name' => "BES.Group=#{group_name}"
    }
  end
end
