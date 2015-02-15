class Antlr2 < PACKMAN::Package
  url 'http://www.antlr2.org/download/antlr-2.7.7.tar.gz'
  sha1 '802655c343cc7806aaf1ec2177a0e663ff209de1'
  version '2.7.7'

  def install
    # Fix bugs.
    PACKMAN.replace 'lib/cpp/antlr/CharScanner.hpp', {
      /^(#include <map>)$/ => "\\1\n#include <strings.h>\n#include <cstdio>\n"
    }
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-csharp
      --disable-java
      --disable-python
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end