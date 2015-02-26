class Openexr < PACKMAN::Package
  url 'http://download.savannah.gnu.org/releases/openexr/openexr-2.1.0.tar.gz'
  sha1 '4a3db5ea527856145844556e0ee349f45ed4cbc7'
  version '2.1.0'

  label 'master_package'
  belongs_to 'openexr'

  depends_on 'openexr_ilmbase'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
    ]
    PACKMAN.set_cppflags_and_ldflags [Openexr]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
