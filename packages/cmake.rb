class Cmake < PACKMAN::Package
  url 'http://www.cmake.org/files/v3.1/cmake-3.1.2.tar.gz'
  sha1 '66c7b73d460daf2e26dc17da1d7e7dfd14bc48fc'
  version '3.0.1'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run "./bootstrap", *args
    PACKMAN.run "make"
    PACKMAN.run "make install"
  end
end
