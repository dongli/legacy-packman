class Cmake < PACKMAN::Package
  url 'http://www.cmake.org/files/v3.3/cmake-3.3.2.tar.gz'
  sha1 '85f4debf7406bb2a436a302bfd51ada2b4e43719'
  version '3.3.2'

  label :compiler_insensitive

  def install
    if PACKMAN.mac? and PACKMAN.compiler(:c).vendor == :gnu
      PACKMAN.report_error "#{PACKMAN.green 'Cmake'} can not be built by GCC in Mac OS X! Use LLVM instead."
    end
    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=2
    ]
    PACKMAN.run "./bootstrap", *args
    PACKMAN.run "make"
    PACKMAN.run "make install"
  end
end
