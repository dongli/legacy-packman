class Hyrax_dap_server < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/dap-server-4.1.4.tar.gz'
  sha1 '4328401e2e051ad9e05a666ad5444a89b88e7fc2'
  version '4.1.4'

  belongs_to 'hyrax'

  depends_on 'libxml2'
  depends_on 'opendap'
  depends_on 'hyrax_bes'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
