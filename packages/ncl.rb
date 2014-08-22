class Ncl < PACKMAN::Package
  url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=474bb254-ba75-11e3-b322-00c0f03d5b7c'
  sha1 '9f7be65e0406a410b27d338309315deac2e64b6c'
  filename 'ncl_ncarg-6.2.0.tar.gz'
  version '6.2.0'
  
  depends_on 'cairo'
  depends_on 'jpeg'
  depends_on 'hdf4'
  depends_on 'hdf5'
  depends_on 'netcdf_c'
  depends_on 'netcdf_fortran'

  def install
    
  end
end