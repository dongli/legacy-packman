class Mpich < PACKMAN::Package
  url 'http://www.mpich.org/static/downloads/3.1.4/mpich-3.1.4.tar.gz'
  sha1 'af4f563e2772d610e57e17420c9dcc5c3c9fec4e'
  version '3.1.4'

  conflicts_with :openmpi, 'They both provide MPI implementation.'

  provides :c => 'mpicc'
  provides :cxx => 'mpic++'
  provides :fortran => { '77' => 'mpif77', '90' => 'mpif90' }

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :gnu, '=~ 5.2' ], :cxx => [ :gnu, '=~ 5.2' ], :fortran => [ :gnu, '=~ 5.2' ]
    sha1 '2780d7bc7788bef8c6eee5964f0a83a1d4e931b3'
    version '3.1.4'
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-maintainer-mode
      --enable-cxx
    ]
    if PACKMAN.has_compiler? :fortran, :not_exit
      args << '--enable-fortran=all'
    else
      args << '--disable-fortran'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
