class Netcdf_cxx < PACKMAN::Package
  url 'https://github.com/Unidata/netcdf-cxx4/archive/v4.2.1.tar.gz'
  sha1 '0bb4a0807f10060f98745e789b6dc06deddf30ff'
  version '4.2.1'

  belongs_to 'netcdf'

  option 'use_mpi' => [:package_name, :boolean]

  depends_on 'netcdf_c'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
    ]
    PACKMAN::AutotoolHelper.set_cppflags_and_ldflags args, [Netcdf]
    if PACKMAN::OS.cygwin_gang?
      args << "LIBS='-L#{Curl.lib} -lcurl -L#{Hdf5.lib} -lhdf5 -lhdf5_hl'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
