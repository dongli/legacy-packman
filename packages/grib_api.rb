class Grib_api < PACKMAN::Package
  url 'https://software.ecmwf.int/wiki/download/attachments/3473437/grib_api-1.12.3.tar.gz'
  sha1 '2764b262c8f081fefb81112f7f7463a3a34b6e66'
  version '1.12.3'

  def install
    PACKMAN.run './configure', "--prefix=#{PACKMAN::Package.prefix(self)}"
    PACKMAN.run 'make install'
  end
end