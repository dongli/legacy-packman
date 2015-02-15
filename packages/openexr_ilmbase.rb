class Openexr_ilmbase < PACKMAN::Package
  url 'http://download.savannah.gnu.org/releases/openexr/ilmbase-2.1.0.tar.gz'
  sha1 '306d76e7a2ac619c2f641f54b59dd95576525192'
  version '2.1.0'

  belongs_to 'openexr'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
