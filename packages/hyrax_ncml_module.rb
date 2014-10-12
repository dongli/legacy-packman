class Hyrax_ncml_module < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/ncml_module-1.2.4.tar.gz'
  sha1 '459e57bf2c911ea119ede375ae7bc933aa2dea09'
  version '1.2.4'

  belongs_to 'hyrax'

  depends_on 'autoconf'
  depends_on 'libxml2'
  depends_on 'opendap'
  depends_on 'hyrax_bes'
  depends_on 'icu4c'

  def install
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-dependency-tracking
      --with-icu-prefix=#{PACKMAN.prefix(Icu4c)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end
