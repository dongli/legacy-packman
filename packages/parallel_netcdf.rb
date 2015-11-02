class Parallel_netcdf < PACKMAN::Package
  url 'http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.6.1.tar.bz2'
  sha1 'f4b220ba64c7725d0bc2cff36974f8c8522c0c45'
  version '1.6.1'

  option :use_mpi => [:package_name, :boolean]

  depends_on :m4
  depends_on mpi if use_mpi? and option_type('use_mpi') == :package_name

  def install
    if not use_mpi?
      PACKMAN.report_error "Option #{PACKMAN.red 'use_mpi'} must be set to build #{PACKMAN.green 'Parallel_netcdf'}!"
    end
    if PACKMAN.compiler(:cxx).vendor == :intel
      # Fix C++ test code bug when using Intel MPI library:
      #   SEEK_SET is #defined but must not be for the C++ binding of MPI. Include mpi.h before stdio.h
      ['test/CXX/nctst.cpp', 'test/CXX/test_classic.cpp'].each do |bug_file|
        PACKMAN.replace bug_file, {
          '#include <pnetcdf>' => '',
          '#include <stdio.h>' => "#include <pnetcdf>\n#include <stdio.h>"
        }
      end
      PACKMAN.append_env 'CXXFLAGS', '-DMPICH_IGNORE_CXX_SEEK -DMPICH_SKIP_MPICXX'
      PACKMAN.replace 'src/libcxx/ncmpi_notyet.cpp', {
        /#include <mpi.h>/ => <<-EOT
          #include <mpi.h>
          #ifdef MPICH_IGNORE_CXX_SEEK
          #include<stdio.h>
          #endif
        EOT
      }
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
