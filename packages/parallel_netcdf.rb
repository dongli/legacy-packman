class Parallel_netcdf < PACKMAN::Package
  url 'http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.5.0.tar.bz2'
  sha1 '41ec358878a97132b3bb1d1f67dcef96c492376c'
  version '1.5.0'

  depends_on options['use_mpi'] if options['use_mpi']

  option 'use_mpi' => :package_name

  def install
    if not options.has_key? 'use_mpi'
      PACKMAN::CLI.report_error "Option #{PACKMAN::CLI.red 'use_mpi'} must be set to build #{PACKMAN::CLI.green 'Parallel_netcdf'}!"
    end
    if PACKMAN::OS.type == :Linux
      PACKMAN.append_customized_flags :all, :pic
    end
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
    ]
    PACKMAN.use_mpi options['use_mpi']
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end
