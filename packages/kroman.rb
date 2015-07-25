class Kroman < PACKMAN::Package
  url 'https://github.com/cheunghy/kroman/archive/v1.0.tar.gz'
  sha1 'f3a9341c4c5b68ed8183a94d00875e41c81c395b'
  version '1.0'
  filename 'kroman-1.0.tar.gz'

  label :compiler_insensitive

  def install
    PACKMAN.run "make install PREFIX=#{prefix}"
  end
end
