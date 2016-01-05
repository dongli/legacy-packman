class Netcdf_fortran < PACKMAN::Package
  url 'https://github.com/Unidata/netcdf-fortran/archive/v4.4.2.tar.gz'
  sha1 '06876d19d3725639003358be6ffbac2ed62362e1'
  version '4.4.2'
  filename 'netcdf-fortran-4.4.2.tar.gz'

  belongs_to :netcdf

  option :use_mpi => [:package_name, :boolean]

  depends_on :netcdf_c

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :gnu, '=~ 5.2' ], :fortran => [ :gnu, '=~ 5.2' ]
    sha1 'd8f070d73860d8be6001761d3e7c5474b3172310'
    version '4.4.2'
  end

  def install
    PACKMAN.handle_unlinked Libressl
    if not PACKMAN.has_compiler? :fortran, :not_exit
      PACKMAN.report_warning "Fortran compiler is not available in this compiler set, skip #{PACKMAN.red 'Netcdf_fortran'}."
      return
    end
    if PACKMAN.mac? and PACKMAN.compiler(:fortran).vendor == :intel
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
    if PACKMAN.cygwin?
      args.map! { |arg| arg =~ /enable-shared/ ? '--enable-shared=no' : arg }
      args << "LIBS='-L#{Curl.lib} -lcurl -L#{Hdf5.lib} -lhdf5_hl -lhdf5 -L#{Szip.lib} -lsz -L#{Zlib.lib} -lz -L#{Netcdf.lib} -lnetcdf'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end

  def check_consistency
    res = `#{link_root}/bin/nc-config --has-pnetcdf`
    if res == 'no' and use_mpi?
      return false
    end
    return true
  end
end
