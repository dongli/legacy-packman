class Netcdf < PACKMAN::Package
  label 'master_package'

  option 'use_mpi' => :package_name
  option 'with_cxx' => true
  option 'with_fortran' => true

  depends_on 'parallel_netcdf', use_mpi?
  depends_on 'netcdf_c'
  depends_on 'netcdf_cxx', with_cxx?
  depends_on 'netcdf_fortran', with_fortran?

  def version
    netcdf_c = PACKMAN::Package.instance :Netcdf_c
    res = "c_#{netcdf_c.version}"
    if with_cxx?
      netcdf_cxx = PACKMAN::Package.instance :Netcdf_cxx
      res << "_cxx_#{netcdf_cxx.version}"
    end
    if with_fortran?
      netcdf_fortran = PACKMAN::Package.instance :Netcdf_fortran
      res << "_fortran_#{netcdf_fortran.version}"
    end
  end
end
