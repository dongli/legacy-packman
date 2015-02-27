class Intltool < PACKMAN::Package
  url 'http://launchpad.net/intltool/trunk/0.50.2/+download/intltool-0.50.2.tar.gz'
  sha1 '7fddbd8e1bf94adbf1bc947cbf3b8ddc2453f8ad'
  version '0.50.2'

  depends_on 'perl_xml_parser'

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
