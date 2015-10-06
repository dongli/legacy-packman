class Cdo < PACKMAN::Package
  url 'https://code.zmaw.de/attachments/download/10198/cdo-1.6.9.tar.gz'
  sha1 '5d2cedadffcdaaa1b9cf49cbc0f524ee417b5326'
  version '1.6.9'

  history do
    url 'https://code.zmaw.de/attachments/download/7220/cdo-1.6.3.tar.gz'
    sha1 '9aa9f2227247eee6e5a0d949f5189f9a0ce4f2f1'
    version '1.6.3'
  end

  depends_on :hdf5
  depends_on :netcdf_c
  depends_on :zlib
  depends_on :szip
  depends_on :jasper
  depends_on :grib_api
  depends_on :udunits
  depends_on :proj
  depends_on :libxml2

  def install
    args = %W[
      --prefix=#{prefix}
      --with-hdf5=#{link_root}
      --with-netcdf=#{link_root}
      --with-zlib=#{link_root}
      --with-szlib=#{link_root}
      --with-jasper=#{link_root}
      --with-grib_api=#{link_root}
      --with-udunits2=#{link_root}
      --with-proj=#{link_root}
      --with-libxml2=#{link_root}
      --disable-dependency-tracking
      --disable-debug
    ]
    if PACKMAN.cygwin?
      args << "LIBS='-lexpat -lcurl -ludunits2 -lgrib_api'"
    else
      args << "LIBS='-lexpat'"
    end
    args << "CFLAGS='-fp-model source'" if PACKMAN.compiler(:c).vendor == :intel
    PACKMAN.run './configure', *args
    if PACKMAN.cygwin?
      PACKMAN.run "make LIBS='-ludunits2 -lexpat -lproj -lgrib_api -lnetcdf'"
    else
      PACKMAN.run 'make -j2'
    end
    PACKMAN.run 'make check' if not skip_test?
    PACKMAN.run 'make install'
  end
end
