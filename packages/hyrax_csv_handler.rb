class Hyrax_csv_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/csv_handler-1.0.4.tar.gz'
  sha1 'ce9ce7618546b3de6d566d48cecb9066526742d9'
  version '1.0.4'

  belongs_to 'hyrax'

  depends_on :curl
  depends_on :opendap
  depends_on :hyrax_bes

  def install
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
