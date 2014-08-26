class Cmake < PACKMAN::Package
  url 'http://www.cmake.org/files/v3.0/cmake-3.0.1.tar.gz'
  sha1 'b7e4acaa7fc7adf54c1b465c712e5ea473b8b74f'
  version '3.0.1'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.run "./bootstrap", *args
    PACKMAN.run "make"
    PACKMAN.run "make install"
  end
end
