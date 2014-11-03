class Parallel_netcdf < PACKMAN::Package
  url 'http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.5.0.tar.bz2'
  sha1 '41ec358878a97132b3bb1d1f67dcef96c492376c'
  version '1.5.0'

  option 'use_mpi' => :package_name

  depends_on 'm4'
  depends_on mpi, use_mpi?

  def install
    if not use_mpi?
      PACKMAN.report_error "Option #{PACKMAN.red 'use_mpi'} must be set to build #{PACKMAN.green 'Parallel_netcdf'}!"
    end
    if PACKMAN::OS.type == :Linux
      PACKMAN.append_customized_flags :pic
    end
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
    ]
    if PACKMAN.compiler_command 'fortran'
      args << '--enable-fortran'
    else
      args << '--disable-fortran'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
