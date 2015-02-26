class Netcdf_fortran < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.1.tar.gz'
  sha1 '452a1b7ef12cbcace770dcc728a7b425cf7fb295'
  version '4.4.1'

  belongs_to 'netcdf'

  option 'use_mpi' => [:package_name, :boolean]

  depends_on 'netcdf_c'

  def install
    if not PACKMAN.check_compiler 'fortran', :not_exit
      PACKMAN.report_warning "Fortran compiler is not available in this compiler set, skip #{PACKMAN.red 'Netcdf_fortran'}."
      return
    end
    if PACKMAN::OS.mac_gang? and PACKMAN.compiler_vendor('fortran') == 'intel'
      PACKMAN.append_env 'FCFLAGS', '-xHost -ip -no-prec-div -mdynamic-no-pic'
      PACKMAN.append_env 'FFLAGS', '-xHost -ip -no-prec-div -mdynamic-no-pic'
      # Follow the fixing in Homebrew. This is documented in http://www.unidata.ucar.edu/software/netcdf/docs/known_problems.html#intel-fortran-macosx.
      PACKMAN.append_env 'lt_cv_ld_force_load', 'no'
    end
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
    ]
    if use_mpi?
      args << '--enable-parallel-tests'
    end
    PACKMAN.set_cppflags_and_ldflags [Curl, Zlib, Hdf5, Netcdf]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end

  def check_consistency
    res = `#{Netcdf.bin}/nc-config --has-pnetcdf`
    if res == 'no' and use_mpi?
      return false
    end
    return true
  end
end
