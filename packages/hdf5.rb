class Hdf5 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.bz2'
  sha1 '712955025f03db808f000d8f4976b8df0c0d37b5'
  version '1.8.13'

  depends_on 'zlib'
  depends_on 'szip'

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --enable-production
      --enable-debug=no
      --disable-dependency-tracking
      --with-zlib=#{PACKMAN::Package.prefix(Zlib)}
      --with-szlib=#{PACKMAN::Package.prefix(Szip)}
      --enable-filters=all
      --enable-static=yes
      --enable-shared=yes
      --enable-cxx
      --enable-fortran
      --enable-fortran2003
    ]
    if PACKMAN::OS.mac_gang? and PACKMAN.compiler_vendor('fortran', PACKMAN.compiler_command('fortran')) == 'intel'
      # Hdf5 has already used libtool to set rpath.
      PACKMAN.append_env "LDFLAGS=''"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make test'
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end
end
