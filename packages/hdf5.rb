class Hdf5 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.bz2'
  sha1 '712955025f03db808f000d8f4976b8df0c0d37b5'
  version '1.8.13'

  option 'use_mpi' => :package_name

  depends_on 'zlib'
  depends_on 'szip'
  depends_on mpi, use_mpi?

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --enable-production
      --enable-debug=no
      --disable-dependency-tracking
      --with-zlib=#{PACKMAN.prefix(Zlib)}
      --with-szlib=#{PACKMAN.prefix(Szip)}
      --enable-filters=all
      --enable-static=yes
      --enable-shared=yes
      --enable-cxx
    ]
    if PACKMAN.compiler_command 'fortran'
      args << '--enable-fortran --enable-fortran2003'
    else
      args << '--disable-fortran'
    end
    if PACKMAN::OS.cygwin_gang?
      ['.', 'c++', 'fortran'].each do |language|
        ["#{language}/src/Makefile", "hl/#{language}/src/Makefile"].each do |makefile|
          ['am', 'in'].each do |suffix|
            PACKMAN.replace "#{makefile}.#{suffix}", {
              /^(\w+)_la_LDFLAGS\s*=\s*(.*)$/ => '\1_la_LDFLAGS = \2 -no-undefined'
            }
          end
        end
      end
      args << '--enable-unsupported'
    end
    if use_mpi?
      args << '--enable-parallel'
      # --enable-cxx and --enable-parallel flags are incompatible.
      args.delete '--enable-cxx'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end

  def check_consistency
    res = PACKMAN.grep "#{PACKMAN.prefix(self)}/lib/libhdf5.settings", /Parallel HDF5:\s*(.*)$/
    if not res.size == 1
      PACKMAN::CLI.report_error "Failed to check consistency of #{PACKMAN::CLI.red 'Hdf5'}! "+
        "Bad content in #{PACKMAN.prefix(self)}/lib/libhdf5.settings."
    end
    if res.first.first == 'no' and use_mpi?
      return false
    end
    return true
  end
end
