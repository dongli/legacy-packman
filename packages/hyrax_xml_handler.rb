class Hyrax_xml_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/xml_data_handler-1.0.4.tar.gz'
  sha1 '67dbbc801093b8f498ea926f3ee4f81d7a042445'
  version '1.0.4'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'libxml2'

  def install
    PACKMAN.replace 'get_xml_data.h', {
      ' XMLWriter *writer' => ' libdap::XMLWriter *writer'
    }
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end