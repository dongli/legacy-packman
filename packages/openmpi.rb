class Openmpi < PACKMAN::Package
  url 'http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.1.tar.bz2'
  sha1 'caf6885f323a38b9c106a7815711313843409478'
  version '1.10.1'

  # Libevent can be downloaded in some network condition!
  # depends_on 'libevent'

  conflicts_with :mpich, 'They both provide MPI implementation.'

  provides :c => 'mpicc'
  provides :cxx => 'mpic++'
  provides :fortran => { '77' => 'mpif77', '90' => 'mpif90' }

  def install
    # --with-libevent=#{Libevent.prefix}
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-ipv6
      --enable-mpi-thread-multiple
      --enable-mpi-f77
      --enable-mpi-f90
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2 all'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
