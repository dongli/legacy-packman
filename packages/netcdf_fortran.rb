class Netcdf_fortran < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.1.tar.gz'
  sha1 '452a1b7ef12cbcace770dcc728a7b425cf7fb295'
  version '4.4.1'

  belongs_to 'netcdf'

  option 'use_mpi' => [:package_name, :boolean]

  # This old version may be cleaned in near future.
  history_version '4.2' do
    url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz'
    sha1 'f1887314455330f4057bc8eab432065f8f6f74ef'
  end

  depends_on 'netcdf_c'

  def install
    if not PACKMAN.check_compiler 'fortran', :not_exit
      PACKMAN.report_warning "Fortran compiler is not available in this compiler set, skip #{PACKMAN.red 'Netcdf_fortran'}."
      return
    end
    # TODO: Turn 'version' from String to VersionSpec.
    cppflags = "-I#{Curl.include} -I#{Zlib.include} -I#{Hdf5.include} -I#{Netcdf.include}"
    if version != '4.4.1'
      # Refer http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg11622.html.
      # Version '4.4.1' does not need the following kludge.
      fortran_compiler = PACKMAN.compiler_command 'fortran'
      case fortran_compiler
      when /gfortran/
        cppflags << ' -DgFortran'
      when /ifort/
        cppflags << ' -DINTEL_COMPILER'
      else
        PACKMAN.report_error "Unsupported Fortran compiler #{fortran_compiler}!"
      end
    end
    PACKMAN.append_env "CPPFLAGS='#{cppflags}'"
    PACKMAN.append_env "LDFLAGS='-L#{Curl.lib} -L#{Zlib.lib} -L#{Hdf5.lib} -L#{Netcdf.lib} -lcurl -lz -lhdf5 -lhdf5_hl -lnetcdf'"
    if PACKMAN::OS.mac_gang? and PACKMAN.compiler_vendor('fortran') == 'intel'
      PACKMAN.append_env "FCFLAGS='-xHost -ip -no-prec-div -mdynamic-no-pic'"
      PACKMAN.append_env "FFLAGS='-xHost -ip -no-prec-div -mdynamic-no-pic'"
      # Follow the fixing in Homebrew. This is documented in http://www.unidata.ucar.edu/software/netcdf/docs/known_problems.html#intel-fortran-macosx.
      PACKMAN.append_env "lt_cv_ld_force_load=no"
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
