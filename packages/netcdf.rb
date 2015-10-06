class Netcdf < PACKMAN::Package
  label :master_package

  option :use_mpi => [ :package_name, :boolean ]
  option :with_cxx => true
  option :with_fortran => true

  depends_on :parallel_netcdf if use_mpi?
  depends_on :netcdf_c
  depends_on :netcdf_cxx if with_cxx?
  depends_on :netcdf_fortran if with_fortran?
end
