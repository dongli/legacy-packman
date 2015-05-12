class Netcdf_c < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.3.1.tar.gz'
  sha1 '074dd8ef6e8dde3f0c26c7bec0b5d3be6a38bbee'
  version '4.3.3.1'

  belongs_to 'netcdf'

  option 'use_mpi' => [:package_name, :boolean]

  depends_on 'm4'
  depends_on 'patch'
  depends_on 'curl'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'hdf5'
  depends_on 'parallel_netcdf' if use_mpi?

  def install
    # NOTE: OpenDAP support should be supported in default, but I still add
    #       '--enable-dap' explicitly for reminding.
    # Build netcdf in parallel: http://www.unidata.ucar.edu/software/netcdf/docs/getting_and_building_netcdf.html#build_parallel
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
      --enable-netcdf4
      --enable-dap
      --disable-doxygen
    ]
    if use_mpi?
      args << '--enable-pnetcdf'
      PACKMAN.set_cppflags_and_ldflags [Curl, Zlib, Szip, Hdf5, Parallel_netcdf]
      # PnetCDF test has bug as discussed in http://www.unidata.ucar.edu/support/help/MailArchives/netcdf/msg12561.html
      PACKMAN.replace 'nc_test/run_pnetcdf_test.sh', { 'mpiexec -n 4' => 'mpiexec -n 2' }
    else
      PACKMAN.set_cppflags_and_ldflags [Curl, Zlib, Szip, Hdf5]
    end
    if PACKMAN.cygwin?
      args.map! { |arg| arg =~ /enable-shared/ ? '--enable-shared=no' : arg }
      args << 'LIBS=-lsz'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end

  def check_consistency
    res = `#{prefix}/bin/nc-config --has-pnetcdf`.strip
    if res == 'no' and use_mpi?
      return false
    end
    return true
  end
end
