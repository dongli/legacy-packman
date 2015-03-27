class Hyrax_hdf5_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/hdf5_handler-2.2.3.tar.gz'
  sha1 '61490e570559a252ab6f6d7a5111acbc4f084eae'
  version '2.2.3'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'hdf5'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-hdf5=#{Hdf5.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
