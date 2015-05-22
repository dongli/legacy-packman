class Perl_xml_parser < PACKMAN::Package
  url 'http://search.cpan.org/CPAN/authors/id/M/MS/MSERGEANT/XML-Parser-2.36.tar.gz'
  sha1 '74acac4f939ebf788d8ef5163cbc9802b1b04bfa'
  version '2.36'

  label :compiler_insensitive

  belongs_to 'perl'

  depends_on 'perl'
  depends_on 'expat'

  def install
    args = %W[
      PREFIX=#{prefix}
      EXPATINCPATH=#{Expat.include}
      EXPATLIBPATH=#{Expat.lib}
    ]
    PACKMAN.run 'perl Makefile.PL', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end
