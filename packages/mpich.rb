class Mpich < PACKMAN::Package
  url 'http://www.mpich.org/static/downloads/3.1.2/mpich-3.1.2.tar.gz'
  sha1 'c5199be7e9f1843b288dba0faf2c071c7a8e999d'
  version '3.1.2'

  conflicts_with 'openmpi' do
    because_they_both_provide 'mpi'
  end

  provide 'c' => 'mpicc'
  provide 'c++' => 'mpic++'
  provide 'fortran:77' => 'mpif77'
  provide 'fortran:90' => 'mpif90'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-maintainer-mode
      --enable-cxx
    ]
    if PACKMAN.has_compiler? 'fortran', :not_exit
      args << '--enable-fortran=all' 
    else
      args << '--disable-fortran'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
