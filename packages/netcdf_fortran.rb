class Netcdf_fortran < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.1.tar.gz'
  sha1 ''
  version '4.4.1'

  # This old version may be cleaned in near future.
  history_version '4.2' do
    url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz'
    sha1 'f1887314455330f4057bc8eab432065f8f6f74ef'
  end

  depends_on 'netcdf_c'

  option 'use_mpi' => :package_name

  def install
    netcdf_c_prefix = PACKMAN::Package.prefix(Netcdf_c)
    PACKMAN.append_env "PATH=#{netcdf_c_prefix}/bin:$PATH"
    # TODO: Turn 'version' from String to VersionSpec.
    if version != '4.4.1'
      PACKMAN.append_env "CPPFLAGS='-I#{netcdf_c_prefix}/include'"
    else
      # Refer http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg11622.html.
      # Version '4.4.1' does not need the following kludge.
      case PACKMAN.compiler_command 'fortran'
      when /gfortran/
        PACKMAN.append_env "CPPFLAGS='-DgFortran -I#{netcdf_c_prefix}/include'"
      when /ifort/
        PACKMAN.append_env "CPPFLAGS='-DINTEL_COMPILER -I#{netcdf_c_prefix}/include'"
      else
        PACKMAN::CLI.under_construction!
      end
    end
    PACKMAN.append_env "LDFLAGS='-L#{netcdf_c_prefix}/lib'"
    if PACKMAN::OS.mac_gang? and PACKMAN.compiler_vendor('fortran') == 'intel'
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
    if options['use_mpi']
      args << '--enable-parallel-tests'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end

  def check_consistency
    res = `#{PACKMAN::Package.prefix(Netcdf_c)}/bin/nc-config --has-pnetcdf`
    if res == 'no' and options['use_mpi']
      return false
    end
    return true
  end
end
