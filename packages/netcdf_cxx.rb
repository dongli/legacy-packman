class Netcdf_cxx < PACKMAN::Package
  url 'https://github.com/Unidata/netcdf-cxx4/archive/v4.2.1.tar.gz'
  sha1 '0bb4a0807f10060f98745e789b6dc06deddf30ff'
  version '4.2.1'
  filename 'netcdf-cxx4-4.2.1.tar.gz'

  belongs_to :netcdf

  option :use_mpi => [:package_name, :boolean]

  depends_on :netcdf_c

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :gnu, '=~ 5.2' ], :cxx => [ :gnu, '=~ 5.2' ]
    sha1 '44878b2347f45e3c63100ae73ca1f4a3b95d86a7'
    version '4.2.1'
  end

  def install
    PACKMAN.handle_unlinked Libressl
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-dap-remote-tests
      --enable-static
      --enable-shared
    ]
    if PACKMAN.cygwin?
      args.map! { |arg| arg =~ /enable-shared/ ? '--enable-shared=no' : arg }
      args << "LIBS='-lcurl -lhdf5_hl -lhdf5 -lsz -lz'"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
