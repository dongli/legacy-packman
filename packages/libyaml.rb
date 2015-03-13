class Libyaml < PACKMAN::Package
  url 'http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz'
  sha1 'f3d404e11bec3c4efcddfd14c42d46f1aabe0b5d'
  version '0.1.6'

  def install
    # Only for 0.1.5 and 0.1.6.
    PACKMAN.replace 'src/scanner.c', {
      ' assert(parser->simple_key_allowed || !required);' => ''
    }
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end