class Opendap < PACKMAN::Package
  url 'http://www.opendap.org/pub/source/libdap-3.14.0.tar.gz'
  sha1 'a95c345da2164ec7a790b34b7f0aeb9227277770'
  version '3.14.0'

  depends_on :flex
  depends_on :bison
  depends_on :uuid
  depends_on :curl
  depends_on :libxml2
  depends_on :openssl

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --with-curl=#{Curl.prefix}
      --with-xml2=#{Libxml2.prefix}
      --with-included-regex
    ]
    PACKMAN.run './configure', *args
    # Regenerate parser codes.
    PACKMAN.work_in 'd4_ce' do
      system 'make clean 1>/dev/null 2>/dev/null'
    end
    # Change UUID API to OSSP version.
    # See discussion here: http://public.kitware.com/pipermail/insight-developers/2009-November/013701.html
    PACKMAN.replace 'DODSFilter.cc', {
      'uuid/uuid.h' => 'uuid.h',
      'uuid_t uu;' => 'uuid_t *uu;',
      'uuid_generate(uu);' => 'uuid_create(&uu);',
      'uuid_unparse' => 'uuid_load'
    }
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
