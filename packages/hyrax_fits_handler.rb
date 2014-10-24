class Hyrax_fits_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/fits_handler-1.0.11.tar.gz'
  sha1 '2cbf1634354a95a87bb961920de94e6506b753df'
  version '1.0.11'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'cfitsio'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --with-cfits=#{PACKMAN.prefix(Cfitsio)}
      LDFLAGS='-lm'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
