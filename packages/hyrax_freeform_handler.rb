class Hyrax_freeform_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/freeform_handler-3.8.8.tar.gz'
  sha1 'ab208cf454033988b08bc2c9c53043adf7ff55cf'
  version '3.8.8'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end