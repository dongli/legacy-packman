class Hyrax_gateway_module < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/gateway_module-1.1.2.tar.gz'
  sha1 'd2c7d49a00b80d7569cb3db7875eea51caae18fb'
  version '1.1.2'

  belongs_to 'hyrax'

  depends_on 'curl'
  depends_on 'libxml2'
  depends_on 'opendap'
  depends_on 'hyrax_bes'

  def install
    args = %W[
      --prefix=#{self.prefix}
      --disable-dependency-tracking
      DAP_CFLAGS='#{`#{Opendap.bin}/dap-config --cflags`.strip}'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    # Due to the invalid URL, the test will fail.
    # PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
