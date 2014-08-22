class Jasper < PACKMAN::Package
  url 'http://download.osgeo.org/gdal/jasper-1.900.1.uuid.tar.gz'
  sha1 'bbf30168ceae74d78e28039972657a90799e68d3'
  version '1.900.1'

  depends_on 'jpeg'

  # TODO: Apply the patch as in Homebrew.

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --enable-shared
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end