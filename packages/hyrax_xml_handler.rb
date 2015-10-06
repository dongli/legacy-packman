class Hyrax_xml_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/xml_data_handler-1.0.5.tar.gz'
  sha1 '6812ad918c2f704a29394ffedacabe8034493e77'
  version '1.0.5'

  belongs_to 'hyrax'

  depends_on :opendap
  depends_on :hyrax_bes
  depends_on :libxml2

  def install
    PACKMAN.replace 'get_xml_data.h', {
      ' XMLWriter *writer' => ' libdap::XMLWriter *writer'
    }
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
