class Cmake < PACKMAN::Package
  url 'http://www.cmake.org/files/v3.2/cmake-3.2.1.tar.gz'
  sha1 '53c1fe2aaae3b2042c0fe5de177f73ef6f7b267f'
  version '3.2.1'

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
