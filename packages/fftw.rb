class Fftw < PACKMAN::Package
  url 'http://www.fftw.org/fftw-3.3.4.tar.gz'
  sha1 'fd508bac8ac13b3a46152c54b7ac885b69734262'
  version '3.3.4'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix self}
      --enable-shared
      --disable-debug
      --enable-threads
      --disable-dependency-tracking
    ]
    args << '--disable-fortran' if PACKMAN.check_compiler 'fortran', :not_exit
    PACKMAN.run './configure --enable-sse2 --enable-single', *args
    PACKMAN.run 'make install'
    PACKMAN.run 'make clean'
    PACKMAN.run './configure --enable-sse2', *args
    PACKMAN.run 'make install'
    PACKMAN.run 'make clean'
    PACKMAN.run './configure --enable-long-double', *args
    PACKMAN.run 'make install'
  end
end