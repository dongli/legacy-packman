class Parallel_netcdf < PACKMAN::Package
  url 'http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.5.0.tar.bz2'
  sha1 '41ec358878a97132b3bb1d1f67dcef96c492376c'
  version '1.5.0'

  option :use_mpi => [:package_name, :boolean]

  depends_on :m4
  depends_on mpi if use_mpi? and option_type('use_mpi') == :package_name

  def install
    if not use_mpi?
      PACKMAN.report_error "Option #{PACKMAN.red 'use_mpi'} must be set to build #{PACKMAN.green 'Parallel_netcdf'}!"
    end
    if not skip_test? and PACKMAN.compiler(:cxx).vendor == :intel
      # Fix C++ test code bug when using Intel MPI library:
      #   SEEK_SET is #defined but must not be for the C++ binding of MPI. Include mpi.h before stdio.h
      ['test/CXX/nctst.cpp', 'test/CXX/test_classic.cpp'].each do |bug_file|
        PACKMAN.replace bug_file, {
          '#include <pnetcdf>' => '',
          '#include <stdio.h>' => "#include <pnetcdf>\n#include <stdio.h>"
        }
      end
    end
    PACKMAN.append_customized_flags(:pic) if PACKMAN.linux?
    args = %W[
      --prefix=#{prefix}
    ]
    if PACKMAN.has_compiler? :fortran, :not_exit
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
