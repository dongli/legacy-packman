class Perl_xml_libxml < PACKMAN::Package
  url 'http://search.cpan.org/CPAN/authors/id/S/SH/SHLOMIF/XML-LibXML-2.0118.tar.gz'
  sha1 '9a404413ec46f0a9aa8a4a55db8bdbcf4288b47c'
  version '2.0118'

  label :compiler_insensitive

  belongs_to 'perl'

  depends_on :perl
  depends_on :libxml2
  depends_on :perl_xml_sax
  depends_on :perl_xml_namespacesupport

  def install
    args = %W[
      PREFIX=#{prefix}
      XMLPREFIX=#{Libxml2.prefix}
    ]
    PACKMAN.run 'perl Makefile.PL', *args
    # TODO: Add '-fPIC' flag elegantly!
    PACKMAN.replace 'Makefile', /CCFLAGS\s*=\s*(.*)$/ => 'CCFLAGS = -fPIC \1'
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end