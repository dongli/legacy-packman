class Libffi < PACKMAN::Package
  url 'https://github.com/libffi/libffi/archive/v3.2.1.tar.gz'
  sha1 '4d8dabf78a9892f207f2968453d4eceb6c48ec26'
  version '3.2.1'
  filename 'libffi-3.2.1.tar.gz'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-debug
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
