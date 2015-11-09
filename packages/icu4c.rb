class Icu4c < PACKMAN::Package
  url 'https://fossies.org/linux/misc/icu4c-55_1-src.tgz'
  sha1 '3bb301c11be0e239c653e8aa2925c53f6f4dc88d'
  version '55.1'

  def install
    # TODO: Figure out how the shared libraries do not work with Hyrax_ncml_module.
    args = %W[
      --prefix=#{prefix}
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
