class Hyrax_dap_server < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/dap-server-4.1.6.tar.gz'
  sha1 '3172ba25cf9b7e8a18932f636ab8afeeb6972269'
  version '4.1.6'

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
