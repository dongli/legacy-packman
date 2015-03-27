class Hyrax_hdf4_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/hdf4_handler-3.11.6.tar.gz'
  sha1 '64bcf29df2670d6b1004ed2d5e606172d669ac18'
  version '3.11.6'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'hdf4'
  # depends_on 'hdf_eos2'

  def install
    # NOTE: The Hdfeos2 support is not compiled successfuly due to:
    # => HDFEOS2ArrayGridGeoField.cc:20:10: fatal error: 'proj.h' file not found
    # => #include <proj.h>
    # --with-hdfeos2=#{Hdf_eos2.prefix}
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-hdf4=#{Hdf4.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
