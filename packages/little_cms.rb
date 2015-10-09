class Little_cms < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/lcms/lcms/2.6/lcms2-2.6.tar.gz'
  sha1 'b0ecee5cb8391338e6c281d1c11dcae2bc22a5d2'
  version '2.6'

  depends_on :jpeg
  depends_on :libtiff
  depends_on :zlib

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-jpeg=#{Jpeg.prefix}
      --with-tiff=#{link_root}
      --with-zlib=#{link_root}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
