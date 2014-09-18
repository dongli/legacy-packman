class Netcdf_fortran < PACKMAN::Package
  url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz'
  sha1 'f1887314455330f4057bc8eab432065f8f6f74ef'
  version '4.2'

  depends_on 'netcdf_c'

  def install
    netcdf_c_prefix = PACKMAN::Package.prefix(Netcdf_c)
    PACKMAN.append_env "PATH=#{netcdf_c_prefix}/bin:$PATH"
    PACKMAN.append_env "CPPFLAGS='-I#{netcdf_c_prefix}/include'"
    PACKMAN.append_env "LDFLAGS='-L#{netcdf_c_prefix}/lib'"
    if PACKMAN::OS.mac_gang? and PACKMAN.compiler_vendor('fortran', PACKMAN.compiler_command('fortran')) == 'intel'
      PACKMAN.append_env "FCFLAGS='-xHost -ip -no-prec-div -mdynamic-no-pic'"
      PACKMAN.append_env "FFLAGS='-xHost -ip -no-prec-div -mdynamic-no-pic'"
      # Follow the fixing in Homebrew. This is documented in http://www.unidata.ucar.edu/software/netcdf/docs/known_problems.html#intel-fortran-macosx.
      PACKMAN.append_env "lt_cv_ld_force_load=no"
    end
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end
end
