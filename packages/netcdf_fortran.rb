class Netcdf_fortran < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.1.tar.gz'
  sha1 '452a1b7ef12cbcace770dcc728a7b425cf7fb295'
  version '4.4.1'

  belongs_to 'netcdf'

  option 'use_mpi' => :package_name

  # This old version may be cleaned in near future.
  history_version '4.2' do
    url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz'
    sha1 'f1887314455330f4057bc8eab432065f8f6f74ef'
  end

  depends_on 'netcdf_c'

  def install
    PACKMAN.check_compiler 'fortran'
    curl = PACKMAN.prefix(Curl)
    zlib = PACKMAN.prefix(Zlib)
    hdf5 = PACKMAN.prefix(Hdf5)
    netcdf_c = PACKMAN.prefix(Netcdf_c)
    PACKMAN.append_env "PATH=#{netcdf_c}/bin:$PATH"
    # TODO: Turn 'version' from String to VersionSpec.
    cppflags = "-I#{curl}/include -I#{zlib}/include -I#{hdf5}/include -I#{netcdf_c}/include"
    if version != '4.4.1'
      # Refer http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg11622.html.
      # Version '4.4.1' does not need the following kludge.
      case PACKMAN.compiler_command 'fortran'
      when /gfortran/
        cppflags << ' -DgFortran'
      when /ifort/
        cppflags << ' -DINTEL_COMPILER'
      else
        PACKMAN::CLI.under_construction!
      end
    end
    PACKMAN.append_env "CPPFLAGS='#{cppflags}'"
    PACKMAN.append_env "LDFLAGS='-L#{curl}/lib -L#{zlib}/lib -L#{hdf5}/lib -L#{netcdf_c}/lib -lcurl -lz -lhdf5 -lhdf5_hl -lnetcdf'"
    if PACKMAN::OS.mac_gang? and PACKMAN.compiler_vendor('fortran') == 'intel'
      PACKMAN.append_env "FCFLAGS='-xHost -ip -no-prec-div -mdynamic-no-pic'"
      PACKMAN.append_env "FFLAGS='-xHost -ip -no-prec-div -mdynamic-no-pic'"
      # Follow the fixing in Homebrew. This is documented in http://www.unidata.ucar.edu/software/netcdf/docs/known_problems.html#intel-fortran-macosx.
      PACKMAN.append_env "lt_cv_ld_force_load=no"
    end
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
    ]
    if use_mpi?
      args << '--enable-parallel-tests'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end

  def check_consistency
    res = `#{PACKMAN.prefix(Netcdf_c)}/bin/nc-config --has-pnetcdf`
    if res == 'no' and use_mpi?
      return false
    end
    return true
  end
end
