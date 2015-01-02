class Regcm < PACKMAN::Package
  url 'http://gforge.ictp.it/gf/download/frsrelease/212/1370/RegCM-4.4.0.tar.gz'
  sha1 '643f209f6bc1ef6311485d5c6e9a2f31269d1ec7'
  version '4.4.0'

  label 'install_with_source'

  option 'use_mpi' => :package_name
  option 'use_clm' => false
  option 'use_clm45' => false
  option 'use_megan' => false
  option 'use_mpiserial' => false

  depends_on 'netcdf'
  depends_on 'hdf5'
  depends_on 'szip'

  def install
    # TODO: How to let user use the MPI library installed by others?
    # if not mpi
    #   PACKMAN.report_error "You should use #{PACKMAN.red '-use_mpi=<...>'} to specify MPI library."
    # end
    PACKMAN.work_in 'RegCM-4.4.0' do
      if PACKMAN.compiler_vendor('fortran') == 'gnu'
        PACKMAN.append_env 'FCFLAGS="$FCFLAGS -fno-range-check"'
      end
      args = %W[
        --with-netcdf=#{PACKMAN.prefix(Netcdf)}
        --with-hdf5=#{PACKMAN.prefix(Hdf5)}
        --with-szip=#{PACKMAN.prefix(Szip)}
      ]
      args << '--enable-clm' if use_clm?
      args << '--enable-clm45' if use_clm45?
      args << '--enable-megan' if use_megan?
      args << '--enable-mpiserial' if use_mpiserial?
      PACKMAN.run './configure', *args
      PACKMAN.run 'make'
      PACKMAN.run 'make install'
    end
  end
end
