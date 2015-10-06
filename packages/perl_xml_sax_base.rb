class Perl_xml_sax_base < PACKMAN::Package
  url 'http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM/XML-SAX-Base-1.08.tar.gz'
  sha1 '5ae6a06e465daa65e1a69d1a6977299084fe9aef'
  version '1.08'

  label :compiler_insensitive

  belongs_to 'perl'

  depends_on :perl

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