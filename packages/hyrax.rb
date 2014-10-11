class Hyrax < PACKMAN::Package
  version '1.9.7'

  label 'master_package'

  depends_on 'tomcat'
  depends_on 'opendap'
  depends_on 'hyrax_olfs'
  depends_on 'hyrax_bes'
  depends_on 'hyrax_dap_server'
  depends_on 'hyrax_netcdf_handler'
  depends_on 'hyrax_hdf4_handler'
  depends_on 'hyrax_hdf5_handler'
  depends_on 'hyrax_ncml_module'
  depends_on 'hyrax_gateway_module'
  depends_on 'hyrax_fileout_netcdf'
  depends_on 'hyrax_freeform_handler'
  depends_on 'hyrax_xml_handler'
  depends_on 'hyrax_csv_handler'
  depends_on 'hyrax_fits_handler'
  # depends_on 'hyrax_ugrid'

  def start
    # Start Hyrax server.
    # - Start Tomcat server with OLFS app.
    PACKMAN.slim_run "startup.sh"
    # - Start BES server.
    if ENV['USER'] != 'root'
      PACKMAN.slim_run "sudo besctl start"
    else
      PACKMAN.slim_run "besctl start"
    end
  end

  def stop
    # Stop Hyrax server.
    # - Stop BES server.
    if ENV['USER'] != 'root'
      PACKMAN.slim_run "sudo besctl stop"
    else
      PACKMAN.slim_run "besctl stop"
    end
    # - Stop Tomcat server with OLFS app.
    PACKMAN.slim_run "shutdown.sh"
  end
end