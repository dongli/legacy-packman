class Wrf < PACKMAN::Package
  label 'master_package'
  label 'install_with_source'

  option 'with_da' => false
  option 'with_arwpost' => false

  depends_on 'wrf_model'
  depends_on 'wrf_wps'
  depends_on 'wrf_da' if with_da?
  depends_on 'wrf_arwpost' if with_arwpost?
end
