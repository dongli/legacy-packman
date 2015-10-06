class Perl_data_dumper < PACKMAN::Package
  url 'http://search.cpan.org/CPAN/authors/id/S/SM/SMUELLER/Data-Dumper-2.154.tar.gz'
  sha1 'e4f716d500d821da3e802513be7f26b24bf795ac'
  version '2.154'

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
