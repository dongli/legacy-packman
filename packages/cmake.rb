class Cmake < PACKMAN::Package
  url 'http://www.cmake.org/files/v3.0/cmake-3.0.0.tar.gz'
  sha1 '4dfd9ee9b829c77175d655f22322f14747f11ad2'
  version '3.0.0'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run "./bootstrap", *args
    PACKMAN.run "make"
    PACKMAN.run "make install"
  end
end
