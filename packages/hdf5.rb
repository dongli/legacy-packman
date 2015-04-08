class Hdf5 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.14.tar.bz2'
  sha1 '3c48bcb0d5fb21a3aa425ed035c08d8da3d5483a'
  version '1.8.14'

  option 'use_mpi' => [:package_name, :boolean]

  depends_on 'zlib'
  depends_on 'szip'
  depends_on mpi if use_mpi?

  if PACKMAN.os_type == :Mac_OS_X and use_mpi?
    PACKMAN.caveat <<-EOT.keep_indent
      Parallel HDF5 can not be built succesfully in Mac OS X!
      PACKMAN developer tried hard to solve this problem, but without success!
    EOT
    exit
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-production
      --enable-debug=no
      --disable-dependency-tracking
      --with-zlib=#{Zlib.prefix}
      --with-szlib=#{Szip.prefix}
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
    if PACKMAN.cygwin?
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
    res = PACKMAN.grep "#{lib}/libhdf5.settings", /Parallel HDF5:\s*(.*)$/
    if not res.size == 1
      PACKMAN.report_error "Failed to check consistency of #{PACKMAN.red 'Hdf5'}! "+
        "Bad content in #{lib}/libhdf5.settings."
    end
    if res.first.first == 'no' and use_mpi?
      return false
    end
    return true
  end
end
