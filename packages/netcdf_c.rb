class Netcdf_c < PACKMAN::Package
  url 'https://github.com/Unidata/netcdf-c/archive/v4.3.3.1.tar.gz'
  sha1 'ae75a0aeb0b90265a225b22a5baaf7031aed039e'
  version '4.3.3.1'
  filename 'netcdf-c-4.3.3.1.tar.gz'

  belongs_to :netcdf

  option :use_mpi => [ :package_name, :boolean ]

  depends_on :m4
  depends_on :patch
  depends_on :curl
  depends_on :zlib
  depends_on :szip
  depends_on :hdf5
  depends_on :parallel_netcdf if use_mpi?

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :gnu, '=~ 5.2' ]
    sha1 'b23e92b67c36f49ae1f563e269ee270835c0c837'
    version '4.3.3.1'
  end

  def install
    PACKMAN.handle_unlinked Libressl
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
    args << '--enable-pnetcdf' if use_mpi?
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
