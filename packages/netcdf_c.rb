class Netcdf_c < PACKMAN::Package
  url 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.2.tar.gz'
  sha1 '6e1bacab02e5220954fe0328d710ebb71c071d19'
  version '4.3.2'

  belongs_to 'netcdf'

  option 'use_mpi' => [:package_name, :boolean]

  depends_on 'patch'
  depends_on 'curl'
  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'hdf5'
  depends_on 'parallel_netcdf' if use_mpi?

  # HDF5 1.8.13 removes symbols related to MPI POSIX VFD, leading to
  # errors when linking hdf5 and netcdf5 such as "undefined reference to
  # `_H5Pset_fapl_mpiposix`". This patch fixes those errors, and has been
  # added upstream. It should be unnecessary once NetCDF releases a new
  # stable version.
  patch do
    url 'https://github.com/Unidata/netcdf-c/commit/435d8a03ed28bb5ad63aff12cbc6ab91531b6bc8.diff'
    sha1 '770ee66026e4625b80711174600fb8c038b48f5e'
    # TODO: Add version check here.
    # valid_only_for '4.3.2'
  end

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
