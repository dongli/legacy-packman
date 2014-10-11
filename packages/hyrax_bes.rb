class Hyrax_bes < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/bes-3.13.1.tar.gz'
  sha1 '18ac1bc46d0f7d01411905d3ef7bc6575f1e8184'
  version '3.13.1'

  belongs_to 'hyrax'

  depends_on 'readline'
  depends_on 'libxml2'
  depends_on 'opendap'
  depends_on 'gdal' # TODO: How to solve gdal failure?

  def install
    # Why set DAP_CFLAGS? Because 'pkg-config --cflags libdap' does not give the
    # include directory of Libxml2!
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      DAP_CFLAGS='#{`#{PACKMAN.prefix(Opendap)}/bin/dap-config --cflags`}'
    ]
    if not PACKMAN::OS.mac_gang?
      args << "CPPFLAGS='-I#{PACKMAN.prefix(Readline)}/include'"
      args << "LDFLAGS='-L#{PACKMAN.prefix(Readline)}/lib'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end