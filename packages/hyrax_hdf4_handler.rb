class Hyrax_hdf4_handler < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/hdf4_handler-3.11.5.tar.gz'
  sha1 '23c9ea8e6ca7e6c1531adf8dc168145b835b4d28'
  version '3.11.5'

  belongs_to 'hyrax'

  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'hdf4'
  # depends_on 'hdf_eos2'

  def install
    # NOTE: The Hdfeos2 support is not compiled successfuly due to:
    # => HDFEOS2ArrayGridGeoField.cc:20:10: fatal error: 'proj.h' file not found
    # => #include <proj.h>
    # --with-hdfeos2=#{PACKMAN.prefix(Hdf_eos2)}
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --with-hdf4=#{PACKMAN.prefix(Hdf4)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end