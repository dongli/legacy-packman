class Perl_xml_namespacesupport < PACKMAN::Package
  url 'http://search.cpan.org/CPAN/authors/id/P/PE/PERIGRIN/XML-NamespaceSupport-1.11.tar.gz'
  sha1 'a948c02de081542f4d30e0efabc2929754b62a3b'
  version '1.11'

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