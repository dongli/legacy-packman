class Hyrax_ugrid < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/ugrid_functions-1.0.1.tar.gz'
  sha1 '46f80f7a0497dc7a0e6019765323b53a494156d1'
  version '1.0.1'

  belongs_to 'hyrax'

  depends_on :curl
  depends_on :libxml2
  depends_on :opendap
  depends_on :hyrax_bes
  # depends_on 'gridfields'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-gridfields=#{Gridfields.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
