class Hdf5 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.14/src/hdf5-1.8.14.tar.bz2'
  sha1 '3c48bcb0d5fb21a3aa425ed035c08d8da3d5483a'
  version '1.8.14'

  option :use_mpi => [:package_name, :boolean]
  option :with_fortran => true

  depends_on :zlib
  depends_on :szip
  depends_on mpi if use_mpi?

  if PACKMAN.mac? and use_mpi?
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
      --with-zlib=#{link_root}
      --with-szlib=#{link_root}
      --enable-filters=all
      --enable-static=yes
      --enable-shared=yes
      --enable-cxx
    ]
    if with_fortran? and PACKMAN.has_compiler? :fortran, :not_exit
      args << '--enable-fortran'
      args << '--enable-fortran2003' if PACKMAN.compiler(:fortran).f2003?
      if PACKMAN.compiler(:fortran).vendor == :gnu and PACKMAN.compiler(:fortran).version <= '4.4.3'
        PACKMAN.replace 'fortran/test/tH5F_F03.f90', {
          /(call verify\("h5fget_file_image_f", file_sz.*)$/i => '!\1'
        }
      end
    else
      args << '--disable-fortran'
    end
    if PACKMAN.cygwin?
      args.map! { |arg| arg =~ /enable-shared/ ? '--enable-shared=no' : arg }
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
