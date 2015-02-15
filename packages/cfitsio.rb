class Cfitsio < PACKMAN::Package
  url 'ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio3370.tar.gz'
  sha1 '48bd6389dcff3228508eec70384f2cae3a88ff32'
  version '3.370'

  def install
    PACKMAN.run "./configure --prefix=#{prefix}"
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end