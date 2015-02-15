class Hyrax_hdf5_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/hdf5_handler-2.2.2.tar.gz'
  sha1 '186ddd49640d1fa9b2ea378e76ed4f26eff8735b'
  version '2.2.2'

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
