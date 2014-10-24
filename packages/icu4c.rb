class Icu4c < PACKMAN::Package
  url 'http://download.icu-project.org/files/icu4c/53.1/icu4c-53_1-src.tgz'
  sha1 '7eca017fdd101e676d425caaf28ef862d3655e0f'
  version '53.1'

  def install
    # TODO: Figure out how the shared libraries do not work with Hyrax_ncml_module.
    args = %W[
      --prefix=#{PACKMAN.prefix(self)}
      --disable-samples
      --disable-tests
      --enable-static
      --disable-shared
    ]
    PACKMAN.work_in 'source' do
      PACKMAN.run './configure', *args
      PACKMAN.run 'make'
      PACKMAN.run 'make install'
    end
  end
end