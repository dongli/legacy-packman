class Cmake < PACKMAN::Package
  url 'http://www.cmake.org/files/v3.4/cmake-3.4.3.tar.gz'
  sha1 '49e4f05d46d4752e514b19ba36bf97d20a7da66a'
  version '3.4.3'

  label :compiler_insensitive

  def install
    args = %W[
      --prefix=#{prefix}
      --system-curl
      --parallel=2
    ]
    PACKMAN.run "./bootstrap", *args
    PACKMAN.run "make"
    PACKMAN.run "make install"
  end
end
