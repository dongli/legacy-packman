class Hdf_eos2 < PACKMAN::Package
  url 'ftp://edhs1.gsfc.nasa.gov/edhs/hdfeos/previous_releases/HDF-EOS2.18v1.00.tar.Z'
  sha1 '25c44407870eaf40fe6148a1a815981c1aabef68'
  version '2.18v1.00'

  depends_on :hdf4
  depends_on :zlib
  depends_on :jpeg

  def install
    args = %W[
      --prefix=#{prefix}
      --with-hdf4=#{Hdf4.prefix}
      --with-zlib=#{Zlib_.prefix}
      --with-szlib=#{Szip.prefix}
      --with-jpeg=#{Jpeg.prefix}
      CC='#{Hdf4.bin}/h4cc -Df2cFortran'
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
    # Bad HDF-EOS2 developer does not install 'include'!
    PACKMAN.work_in 'include' do
      PACKMAN.run 'make install'
    end
  end
end
