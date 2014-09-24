class Hdf5 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.bz2'
  sha1 '712955025f03db808f000d8f4976b8df0c0d37b5'
  version '1.8.13'

  depends_on 'zlib'
  depends_on 'szip'
  depends_on options['use_mpi'] if options['use_mpi']

  option 'skip_test' => :boolean
  option 'use_mpi' => :package_name

  def install
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --enable-production
      --enable-debug=no
      --disable-dependency-tracking
      --with-zlib=#{PACKMAN::Package.prefix(Zlib)}
      --with-szlib=#{PACKMAN::Package.prefix(Szip)}
      --enable-filters=all
      --enable-static=yes
      --enable-shared=yes
      --enable-cxx
      --enable-fortran
      --enable-fortran2003
    ]
    if options['use_mpi']
      args << '--enable-parallel'
      # --enable-cxx and --enable-parallel flags are incompatible.
      args.delete '--enable-cxx'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make test' if not options['skip_test']
    PACKMAN.run 'make install'
    PACKMAN.clean_env
  end

  def check_consistency
    res = PACKMAN.grep "#{PACKMAN::Package.prefix(self)}/lib/libhdf5.settings", /Parallel HDF5:\s*(.*)$/
    if not res.size == 1
      PACKMAN::CLI.report_error "Failed to check consistency of #{PACKMAN::CLI.red 'Hdf5'}! "+
        "Bad content in #{PACKMAN::Package.prefix(self)}/lib/libhdf5.settings."
    end
    if res.first.first == 'no' and options['use_mpi']
      return false
    end
    return true
  end
end
