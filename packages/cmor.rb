class Cmor < PACKMAN::Package
  url 'https://github.com/PCMDI/cmor/archive/CMOR-2.9.1.tar.gz'
  sha1 '1e2d8e539ff4deb76b98886f28b1881464017a2a'
  version '2.9.1'

  depends_on :uuid
  depends_on :zlib
  depends_on :udunits
  depends_on :netcdf_c
  depends_on :netcdf_fortran

  def install
    PACKMAN.replace 'configure', /(RTAG="none")/ => "\\1\ntarget_os=none\n"
    args = %W[
      --prefix=#{prefix}
      --with-uuid=#{link_root}
      --with-udunits2=#{link_root}
      --with-netcdf=#{link_root}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
