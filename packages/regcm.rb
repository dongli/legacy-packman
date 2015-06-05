class Regcm < PACKMAN::Package
  url 'http://gforge.ictp.it/gf/download/frsrelease/217/1375/RegCM-4.4.5.tar.gz'
  sha1 '9bb6a5dcb9fc70203c3465c9a4cc1bf9424c3ae2'
  version '4.4.5'

  label :installed_with_source

  option 'use_mpi' => [:package_name, :boolean]
  option 'use_clm' => false
  option 'use_clm45' => false
  option 'use_megan' => false

  depends_on 'mpich' if use_mpi? and mpi == 'mpich'
  depends_on 'openmpi' if use_mpi? and mpi == 'openmpi'
  depends_on 'netcdf'
  depends_on 'hdf5'
  depends_on 'szip'

  def install
    PACKMAN.work_in 'RegCM-4.4.5' do
      if PACKMAN.compiler('fortran').vendor == 'gnu'
        PACKMAN.append_env 'FCFLAGS', '-fno-range-check -std=legacy'
      end
      args = %W[
        --with-netcdf=#{Netcdf.prefix}
        --with-hdf5=#{Hdf5.prefix}
        --with-szip=#{Szip.prefix}
      ]
      args << '--enable-clm' if use_clm?
      args << '--enable-clm45' if use_clm45?
      args << '--enable-megan' if use_megan?
      args << '--enable-mpiserial' if not use_mpi?
      PACKMAN.run './configure', *args
      PACKMAN.run 'make'
      PACKMAN.run 'make install'
    end
  end
end
