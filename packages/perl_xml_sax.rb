class Perl_xml_sax < PACKMAN::Package
  url 'http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM/XML-SAX-0.99.tar.gz'
  sha1 '9685c417627d75ae18ab0be3b1562608ee093d5c'
  version '0.99'

  label :compiler_insensitive

  belongs_to 'perl'

  depends_on :perl
  depends_on :perl_xml_sax_base
  depends_on :perl_xml_namespacesupport

  def install
    args = %W[
      PREFIX=#{prefix}
    ]
    PACKMAN.run 'perl Makefile.PL', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end